import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kaptur/core/config/app_config.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/core/utils/snackbar_utils.dart';
import 'package:kaptur/data/models/event_model.dart';
import 'package:kaptur/data/models/photo_model.dart';
import 'package:kaptur/data/services/photo_service.dart';
import 'package:kaptur/data/services/tus_uploader.dart';

/// EventDetailController manages state and business logic for the Event
/// Details screen: event info, its photo grid, and the photo upload flow.
///
/// NOTE FOR LEARNERS:
/// 1. Uploads follow the resumable TUS protocol: `POST /events/{id}/photos/init`
///    returns a `photoId` + TUSd URL, then [TusUploader] pushes the bytes in
///    chunks (with progress). TUSd's pre-create hook ties the upload to `photoId`.
/// 2. Failures are surfaced via error snackbars + leveled logs — never masked
///    with mock or offline fallback data.
class EventDetailController extends GetxController {
  final PhotoService _photoService = PhotoService();
  final TusUploader _tusUploader = TusUploader();
  final ImagePicker _picker = ImagePicker();

  /// The event opened from the Home dashboard (passed via route arguments).
  late final EventModel event;

  // Reactive state
  final RxList<PhotoModel> photos = <PhotoModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isDragOver = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxString uploadFileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    LoggerUtility.debug('EventDetailController.onInit');
    final args = Get.arguments;
    if (args is! EventModel) {
      LoggerUtility.error('EventDetailController: missing EventModel route arguments');
      throw ArgumentError('EventDetail route requires an EventModel argument');
    }
    event = args;
    LoggerUtility.info('Opening event details: ${event.evntId} (${event.eventTitle})');
    fetchPhotos();
  }

  /// Fetches the event's photos (`GET /events/{id}/photos`).
  Future<void> fetchPhotos() async {
    LoggerUtility.debug('fetchPhotos: event=${event.evntId}');
    isLoading.value = true;
    try {
      final response = await _photoService.getPhotos(event.evntId);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final loaded = data.map((item) => PhotoModel.fromJson(item)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        photos.value = loaded;
        LoggerUtility.info('Loaded ${photos.length} photos for event ${event.evntId}');
      } else {
        LoggerUtility.error('Failed to load photos: ${response.statusCode}');
        AppSnackbar.error(
          title: 'Load Failed',
          message: 'Server returned status ${response.statusCode}.',
        );
      }
    } catch (e, st) {
      LoggerUtility.error('Network error fetching photos', e, st);
      AppSnackbar.error(
        title: 'Network Error',
        message: 'Could not reach the server. Check your connection.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the gallery/device picker and uploads every selected image.
  /// Works on Android (photo gallery) and web (file chooser dialog).
  Future<void> pickAndUploadImages() async {
    LoggerUtility.debug('pickAndUploadImages: opening image picker');
    final List<XFile> picked;
    try {
      picked = await _picker.pickMultiImage();
    } catch (e, st) {
      LoggerUtility.error('Image picker failed', e, st);
      AppSnackbar.error(
        title: 'Picker Error',
        message: 'Could not open the image picker.',
      );
      return;
    }

    if (picked.isEmpty) {
      LoggerUtility.debug('pickAndUploadImages: no images selected');
      return;
    }

    await uploadFiles(picked);
  }

  /// Uploads images dropped onto the screen (web/desktop drag & drop).
  Future<void> addDroppedFiles(List<XFile> files) async {
    final images =
        files.where((f) => _isImageFile(f.name, f.mimeType)).toList();
    if (images.isEmpty) {
      LoggerUtility.warning('addDroppedFiles: no image files in ${files.length} dropped file(s)');
      AppSnackbar.error(
        title: 'Unsupported Files',
        message: 'Only image files can be uploaded.',
      );
      return;
    }
    LoggerUtility.info('Received ${images.length} dropped image(s)');
    await uploadFiles(images);
  }

  /// Shared upload pipeline for picked or dropped images.
  Future<void> uploadFiles(List<XFile> files) async {
    LoggerUtility.info('Uploading ${files.length} image(s) to event ${event.evntId}');
    isUploading.value = true;
    uploadProgress.value = 0;
    int succeeded = 0;
    int failed = 0;

    for (final file in files) {
      uploadFileName.value = file.name;
      try {
        await _uploadOne(file);
        succeeded++;
      } catch (e, st) {
        failed++;
        LoggerUtility.error('Upload failed for ${file.name}', e, st);
      }
    }

    isUploading.value = false;
    uploadFileName.value = '';

    if (succeeded > 0) {
      AppSnackbar.success(
        title: 'Upload Complete',
        message: '$succeeded photo(s) uploaded successfully!',
      );
      await fetchPhotos();
    }
    if (failed > 0) {
      AppSnackbar.error(
        title: 'Upload Failed',
        message: '$failed photo(s) could not be uploaded. Check logs for details.',
      );
    }
  }

  /// Uploads a single picked image: metadata init → TUS create → chunked PATCH.
  Future<void> _uploadOne(XFile file) async {
    LoggerUtility.debug('_uploadOne: ${file.name}');

    final int totalBytes = await file.length();
    final String fileType =
        file.mimeType ?? _guessMimeType(file.name) ?? 'application/octet-stream';

    // 1. Init metadata on Spring Boot → photoId + TUSd collection URL.
    final initResponse = await _photoService.initUpload(
      event.evntId,
      filename: file.name,
      fileType: fileType,
      fileSizeInKb: (totalBytes / 1024).ceil(),
    );

    if (initResponse.statusCode != 201 && initResponse.statusCode != 200) {
      throw Exception('Upload init failed with status ${initResponse.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(initResponse.body);
    final String photoId = data['photoId']?.toString() ?? '';
    final String collectionUrl =
        AppConfig.resolveMediaUrl(data['tusdUploadUrl']?.toString() ?? '');
    if (photoId.isEmpty || collectionUrl.isEmpty) {
      throw Exception('Upload init returned no photoId/tusdUploadUrl');
    }

    // 2. Push the bytes to TUSd with progress reporting.
    await _tusUploader.upload(
      collectionUrl: collectionUrl,
      photoId: photoId,
      file: file,
      onProgress: (p) => uploadProgress.value = p,
    );

    LoggerUtility.info('Photo uploaded: photoId=$photoId, name=${file.name}');
  }

  /// Deletes (soft) a photo after UI confirmation (`DELETE /events/{id}/photos/{photoId}`).
  Future<void> deletePhoto(String photoId) async {
    LoggerUtility.info('Deleting photo $photoId from event ${event.evntId}');
    try {
      final response = await _photoService.deletePhoto(event.evntId, photoId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        photos.removeWhere((p) => p.photoId == photoId);
        AppSnackbar.success(title: 'Photo Deleted', message: 'Photo removed successfully');
      } else {
        LoggerUtility.error('Photo delete failed: ${response.statusCode}');
        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Server returned status ${response.statusCode}.',
        );
      }
    } catch (e, st) {
      LoggerUtility.error('Network error deleting photo', e, st);
      AppSnackbar.error(
        title: 'Network Error',
        message: 'Could not reach the server. Photo was not deleted.',
      );
    }
  }

  /// Total upload size of all photos, formatted for the stats row.
  String get formattedTotalSize {
    final double totalMb =
        photos.fold(0.0, (sum, p) => sum + p.fileSizeInKb / 1024);
    if (totalMb > 1024) return '${(totalMb / 1024).toStringAsFixed(2)} GB';
    return '${totalMb.toStringAsFixed(1)} MB';
  }

  String? _guessMimeType(String filename) {
    final String ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return null;
    }
  }

  /// Whether a picked/dropped file is an image (by MIME type or extension).
  bool _isImageFile(String name, String? mimeType) {
    if (mimeType != null && mimeType.startsWith('image/')) return true;
    return _guessMimeType(name) != null;
  }
}

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_constants.dart';

/// This service handles all HTTP network requests related to Photos
/// (metadata only — file bytes are exchanged directly with TUSd).
///
/// NOTE FOR LEARNERS:
/// 1. Init: `POST /events/{id}/photos/init` creates a PENDING photo record and
///    returns `photoId` + the TUSd upload URL where the bytes must be sent.
/// 2. Listing: `GET /events/{id}/photos` returns metadata + a `downloadUrl`
///    served by TUSd (`/files/{photoId}`).
/// 3. Deleting: `DELETE /events/{id}/photos/{photoId}` soft-deletes a photo.
class PhotoService {
  final ApiClient _apiClient = ApiClient();

  String _photosPath(String eventId) => '${ApiConstants.eventsPath}/$eventId/photos';

  /// Fetches all non-deleted photos for an event (`GET /events/{id}/photos`).
  Future<http.Response> getPhotos(String eventId) async {
    return _apiClient.get(_photosPath(eventId));
  }

  /// Initiates a photo upload (`POST /events/{id}/photos/init`).
  /// Backend expects `PhotoUploadRequest`: `filename`, `fileType`, `fileSizeInKb`.
  Future<http.Response> initUpload(
    String eventId, {
    required String filename,
    required String fileType,
    required int fileSizeInKb,
  }) async {
    return _apiClient.post(
      '${_photosPath(eventId)}/init',
      body: {
        'filename': filename,
        'fileType': fileType,
        'fileSizeInKb': fileSizeInKb,
      },
    );
  }

  /// Soft-deletes a photo (`DELETE /events/{id}/photos/{photoId}`).
  Future<http.Response> deletePhoto(String eventId, String photoId) async {
    return _apiClient.delete('${_photosPath(eventId)}/$photoId');
  }
}

/// Represents a photo's metadata in our application (UI display + backend JSON).
///
/// NOTE FOR LEARNERS:
/// 1. The Spring Boot backend returns `PhotoResponse` fields (`photoId`, `filename`, ...).
/// 2. File bytes never travel through Spring Boot — `downloadUrl` points at the
///    TUSd server (`http://localhost:1080/files/{photoId}`) which streams from S3.
/// 3. `photoStatus` mirrors the upload lifecycle: PENDING → UPLOADING → COMPLETED (or FAILED).
class PhotoModel {
  final String photoId;
  final String filename;
  final String fileType;
  final int fileSizeInKb;
  final String? photoPath;
  final String photoStatus;
  final String? uploadedByKptId;
  final String? uploadedByName;
  final DateTime createdAt;
  final DateTime? uploadCompletedAt;
  final String? downloadUrl;

  PhotoModel({
    required this.photoId,
    required this.filename,
    required this.fileType,
    required this.fileSizeInKb,
    this.photoPath,
    required this.photoStatus,
    this.uploadedByKptId,
    this.uploadedByName,
    required this.createdAt,
    this.uploadCompletedAt,
    this.downloadUrl,
  });

  bool get isCompleted => photoStatus == 'COMPLETED';

  /// Creates a [PhotoModel] from a backend JSON map (`PhotoResponse`).
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    DateTime? parsedCompletedAt;
    if (json['uploadCompletedAt'] != null) {
      try {
        parsedCompletedAt = DateTime.parse(json['uploadCompletedAt'].toString());
      } catch (_) {}
    }

    return PhotoModel(
      photoId: json['photoId']?.toString() ?? '',
      filename: json['filename']?.toString() ?? 'photo',
      fileType: json['fileType']?.toString() ?? 'application/octet-stream',
      fileSizeInKb: json['fileSizeInKb'] is num
          ? (json['fileSizeInKb'] as num).toInt()
          : int.tryParse(json['fileSizeInKb']?.toString() ?? '0') ?? 0,
      photoPath: json['photoPath']?.toString(),
      photoStatus: json['photoStatus']?.toString() ?? 'PENDING',
      uploadedByKptId: json['uploadedByKptId']?.toString(),
      uploadedByName: json['uploadedByName']?.toString(),
      createdAt: parsedCreatedAt,
      uploadCompletedAt: parsedCompletedAt,
      downloadUrl: json['downloadUrl']?.toString(),
    );
  }

  /// Converts this [PhotoModel] into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'photoId': photoId,
      'filename': filename,
      'fileType': fileType,
      'fileSizeInKb': fileSizeInKb,
      if (photoPath != null) 'photoPath': photoPath,
      'photoStatus': photoStatus,
      if (uploadedByKptId != null) 'uploadedByKptId': uploadedByKptId,
      if (uploadedByName != null) 'uploadedByName': uploadedByName,
      'createdAt': createdAt.toIso8601String(),
      if (uploadCompletedAt != null)
        'uploadCompletedAt': uploadCompletedAt!.toIso8601String(),
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
    };
  }
}

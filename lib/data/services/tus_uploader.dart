import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:kaptur/core/config/app_config.dart';
import 'package:kaptur/core/utils/app_logger.dart';

/// Minimal TUS protocol client (https://tus.io) used to push photo bytes to
/// the TUSd server. Metadata lives in Spring Boot; bytes never do.
///
/// Flow per file:
///   1. `POST` to the TUSd collection URL with `Upload-Length` and
///      `Upload-Metadata` (includes our `photoId`; the backend's pre-create
///      hook forces TUSd to use it as the upload ID).
///   2. Repeated `PATCH` calls with `Upload-Offset` send the bytes in chunks,
///      which also gives us upload progress for the UI.
class TusUploader {
  static const String _tusVersion = '1.0.0';
  static const int _chunkSize = 1024 * 1024; // 1 MB per PATCH

  /// Uploads [file] to TUSd and returns the final upload URL.
  ///
  /// [collectionUrl] is the TUSd base URL returned by `/photos/init`
  /// (already host-resolved via `AppConfig.resolveMediaUrl`).
  Future<String> upload({
    required String collectionUrl,
    required String photoId,
    required XFile file,
    void Function(double progress)? onProgress,
  }) async {
    LoggerUtility.debug('TusUploader.upload start: photoId=$photoId, file=${file.name}');

    final int totalBytes = await file.length();
    final Uri uploadUri = await _createUpload(
      collectionUrl: collectionUrl,
      photoId: photoId,
      file: file,
      totalBytes: totalBytes,
    );

    // On web `XFile.openRead()` has no random-access reader: cross_file
    // re-hydrates the whole Blob over an XHR on every call, so reading chunk by
    // chunk would load the entire file N times. Buffer it once and slice in
    // memory instead. IO platforms keep streaming straight from disk.
    final Uint8List? webBytes = kIsWeb ? await file.readAsBytes() : null;
    if (webBytes != null) {
      LoggerUtility.debug(
          'TusUploader: buffered $webBytes.length byte(s) for web chunking');
    }

    int offset = 0;
    onProgress?.call(0);
    while (offset < totalBytes) {
      final int end = min(offset + _chunkSize, totalBytes);
      final List<int> chunk = webBytes != null
          ? Uint8List.sublistView(webBytes, offset, end)
          : await _readChunk(file, offset, end);
      offset = await _patchChunk(uploadUri, offset, chunk);
      onProgress?.call(totalBytes == 0 ? 1 : offset / totalBytes);
      LoggerUtility.debug('TusUploader PATCH photoId=$photoId offset=$offset/$totalBytes');
    }

    LoggerUtility.info('TusUploader.upload complete: photoId=$photoId, bytes=$totalBytes');
    return uploadUri.toString();
  }

  /// Step 1 — creates the upload on TUSd and returns its upload URL.
  Future<Uri> _createUpload({
    required String collectionUrl,
    required String photoId,
    required XFile file,
    required int totalBytes,
  }) async {
    final Uri base = Uri.parse(collectionUrl);
    final response = await http.post(
      base,
      headers: {
        'Tus-Resumable': _tusVersion,
        'Upload-Length': totalBytes.toString(),
        'Upload-Metadata': _encodeMetadata({
          'photoId': photoId,
          'filename': file.name,
          'filetype': file.mimeType ?? 'application/octet-stream',
        }),
      },
    );

    if (response.statusCode != 201) {
      LoggerUtility.error(
          'TUS create failed: photoId=$photoId, status=${response.statusCode}');
      throw Exception('TUS create failed with status ${response.statusCode}');
    }

    final String? location = response.headers['location'];
    final Uri uploadUri = location == null || location.isEmpty
        ? base.resolve(photoId)
        : base.resolve(location);
    // The Location header may still carry `localhost` — normalize the host.
    return Uri.parse(AppConfig.resolveMediaUrl(uploadUri.toString()));
  }

  /// Step 2 — sends one chunk with `Upload-Offset` and returns the new offset.
  Future<int> _patchChunk(Uri uploadUri, int offset, List<int> chunk) async {
    final request = http.Request('PATCH', uploadUri)
      ..headers.addAll({
        'Tus-Resumable': _tusVersion,
        'Upload-Offset': offset.toString(),
        'Content-Type': 'application/offset+octet-stream',
      })
      ..bodyBytes = chunk;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 204) {
      LoggerUtility.error(
          'TUS patch failed: uri=$uploadUri, offset=$offset, status=${response.statusCode}');
      throw Exception('TUS patch failed with status ${response.statusCode}');
    }

    final String? newOffset = response.headers['upload-offset'];
    return newOffset != null ? int.parse(newOffset) : offset + chunk.length;
  }

  /// Reads bytes in [start, end) via the platform-safe [XFile.openRead] stream.
  ///
  /// IO platforms only — web buffers the file once and slices it in memory.
  Future<List<int>> _readChunk(XFile file, int start, int end) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in file.openRead(start, end)) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  }

  /// TUS `Upload-Metadata`: comma-separated `key base64(value)` pairs.
  String _encodeMetadata(Map<String, String> values) {
    return values.entries
        .map((e) => '${e.key} ${base64.encode(utf8.encode(e.value))}')
        .join(',');
  }
}

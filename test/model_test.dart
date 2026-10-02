import 'package:flutter_test/flutter_test.dart';

import 'package:kaptur/data/models/event_model.dart';
import 'package:kaptur/data/models/photo_model.dart';

void main() {
  group('EventModel', () {
    test('parses backend EventResponse JSON', () {
      final event = EventModel.fromJson({
        'evntId': 'abc-123',
        'eventTitle': 'Tech Gala',
        'description': 'Annual gala night',
        'eventDate': '2026-08-15',
        'eventLocation': 'Grand Ballroom',
        'creatorName': 'Koustav',
        'createdAt': '2026-09-01T10:00:00',
      });

      expect(event.id, 'abc-123');
      expect(event.name, 'Tech Gala');
      expect(event.description, 'Annual gala night');
      expect(event.eventDate, '2026-08-15');
      expect(event.eventLocation, 'Grand Ballroom');
      expect(event.creatorName, 'Koustav');
      expect(event.imageCount, 0);
    });

    test('falls back to defaults for missing fields', () {
      final event = EventModel.fromJson({'evntId': 'x'});
      expect(event.name, 'Untitled Event');
      expect(event.imageCount, 0);
      expect(event.sizeInMb, 0.0);
    });
  });

  group('PhotoModel', () {
    test('parses backend PhotoResponse JSON', () {
      final photo = PhotoModel.fromJson({
        'photoId': 'photo-1',
        'filename': 'shot.jpg',
        'fileType': 'image/jpeg',
        'fileSizeInKb': 2048,
        'photoStatus': 'COMPLETED',
        'uploadedByName': 'Koustav',
        'createdAt': '2026-09-01T10:00:00',
        'uploadCompletedAt': '2026-09-01T10:01:00',
        'downloadUrl': 'http://localhost:1080/files/photo-1',
      });

      expect(photo.photoId, 'photo-1');
      expect(photo.filename, 'shot.jpg');
      expect(photo.fileSizeInKb, 2048);
      expect(photo.isCompleted, isTrue);
      expect(photo.downloadUrl, 'http://localhost:1080/files/photo-1');
    });

    test('non-COMPLETED photos are not ready for display', () {
      final photo = PhotoModel.fromJson({
        'photoId': 'photo-2',
        'filename': 'a.png',
        'fileType': 'image/png',
        'fileSizeInKb': 10,
        'photoStatus': 'UPLOADING',
        'createdAt': '2026-09-01T10:00:00',
      });
      expect(photo.isCompleted, isFalse);
    });
  });
}

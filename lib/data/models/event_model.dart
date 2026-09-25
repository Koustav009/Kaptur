/// Represents an Event in our application (both for UI display and backend JSON data).
/// 
/// NOTE FOR LEARNERS:
/// 1. Our Spring Boot backend returns fields like `evntId` and `eventTitle`.
/// 2. Our Flutter UI code uses getters (`id` and `name`) for convenient access.
/// 3. `fromJson` converts database/network JSON maps into Dart objects.
/// 4. `toJson` converts Dart objects into JSON maps when sending requests to the backend.
class EventModel {
  final String evntId;
  final String eventTitle;
  final String? description;
  final String? eventDate;
  final String? eventLocation;
  final String? creatorId;
  final String? creatorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // UI specific stats (defaults to 0 if not provided by backend summary yet)
  final int imageCount;
  final double sizeInMb;

  EventModel({
    required this.evntId,
    required this.eventTitle,
    this.description,
    this.eventDate,
    this.eventLocation,
    this.creatorId,
    this.creatorName,
    required this.createdAt,
    this.updatedAt,
    this.imageCount = 0,
    this.sizeInMb = 0.0,
  });

  // Backwards compatibility getters so existing UI screens (`HomeScreen`, `HomeController`) work without modification
  String get id => evntId;
  String get name => eventTitle;

  /// Creates an [EventModel] from a backend JSON map (`EventResponse`).
  factory EventModel.fromJson(Map<String, dynamic> json) {
    // Safely parse date or fallback to current time if missing
    DateTime parsedCreatedAt = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    DateTime? parsedUpdatedAt;
    if (json['updatedAt'] != null) {
      try {
        parsedUpdatedAt = DateTime.parse(json['updatedAt'].toString());
      } catch (_) {}
    }

    return EventModel(
      evntId: json['evntId']?.toString() ?? json['id']?.toString() ?? '',
      eventTitle: json['eventTitle']?.toString() ?? json['name']?.toString() ?? 'Untitled Event',
      description: json['description']?.toString(),
      eventDate: json['eventDate']?.toString(),
      eventLocation: json['eventLocation']?.toString(),
      creatorId: json['creatorId']?.toString(),
      creatorName: json['creatorName']?.toString(),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      imageCount: json['imageCount'] is int
          ? json['imageCount']
          : int.tryParse(json['imageCount']?.toString() ?? '0') ?? 0,
      sizeInMb: json['sizeInMb'] is num
          ? (json['sizeInMb'] as num).toDouble()
          : double.tryParse(json['sizeInMb']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  /// Converts this [EventModel] into a JSON map to send to backend or storage.
  Map<String, dynamic> toJson() {
    return {
      'evntId': evntId,
      'eventTitle': eventTitle,
      if (description != null) 'description': description,
      if (eventDate != null) 'eventDate': eventDate,
      if (eventLocation != null) 'eventLocation': eventLocation,
      if (creatorId != null) 'creatorId': creatorId,
      if (creatorName != null) 'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'imageCount': imageCount,
      'sizeInMb': sizeInMb,
    };
  }

  /// Helper method to create a copy of this object with updated values.
  EventModel copyWith({
    String? evntId,
    String? eventTitle,
    String? description,
    String? eventDate,
    String? eventLocation,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? imageCount,
    double? sizeInMb,
  }) {
    return EventModel(
      evntId: evntId ?? this.evntId,
      eventTitle: eventTitle ?? this.eventTitle,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventLocation: eventLocation ?? this.eventLocation,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageCount: imageCount ?? this.imageCount,
      sizeInMb: sizeInMb ?? this.sizeInMb,
    );
  }
}

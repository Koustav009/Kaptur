class EventModel {
  final String id;
  final String name;
  final int imageCount;
  final double sizeInMb;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.name,
    required this.imageCount,
    required this.sizeInMb,
    required this.createdAt,
  });
}

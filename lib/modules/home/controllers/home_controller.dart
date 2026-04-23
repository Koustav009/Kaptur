import 'package:get/get.dart';
import '../../../data/models/event_model.dart';

class HomeController extends GetxController {
  // Mock data for events
  final RxList<EventModel> events = <EventModel>[
    EventModel(
      id: '1',
      name: 'Wedding Anniversary',
      imageCount: 124,
      sizeInMb: 450.5,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EventModel(
      id: '2',
      name: 'Beach Trip 2024',
      imageCount: 85,
      sizeInMb: 320.0,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    EventModel(
      id: '3',
      name: 'Birthday Party',
      imageCount: 210,
      sizeInMb: 890.2,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    EventModel(
      id: '4',
      name: 'Corporate Meetup',
      imageCount: 45,
      sizeInMb: 150.8,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ].obs;

  // Calculated Stats
  int get totalEvents => events.length;
  
  int get totalImages => events.fold(0, (sum, event) => sum + event.imageCount);
  
  double get totalStorageMb => events.fold(0.0, (sum, event) => sum + event.sizeInMb);

  String get formattedTotalStorage {
    if (totalStorageMb > 1024) {
      return '${(totalStorageMb / 1024).toStringAsFixed(2)} GB';
    }
    return '${totalStorageMb.toStringAsFixed(1)} MB';
  }

  void deleteEvent(String id) {
    events.removeWhere((e) => e.id == id);
  }
}

import 'dart:convert';
import 'package:get/get.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/core/utils/snackbar_utils.dart';
import 'package:kaptur/data/models/event_model.dart';
import 'package:kaptur/data/services/event_service.dart';

/// HomeController manages state and business logic for the Dashboard / Home Screen.
/// 
/// NOTE FOR LEARNERS:
/// 1. We use GetX (`RxList`, `RxBool`) for reactive state management. When `events` changes, the UI updates automatically.
/// 2. We inject `EventService` to talk to our Spring Boot backend REST endpoints (`/events`).
/// 3. If the network is offline or backend is unreachable, we gracefully fall back to local mock data so you can still test the UI.
class HomeController extends GetxController {
  final EventService _eventService = EventService();

  // Reactive state
  final RxList<EventModel> events = <EventModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch events right when the controller initializes
    fetchEvents();
  }

  /// Fetches all events from our Spring Boot backend (`GET /events`).
  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final response = await _eventService.getEvents();
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        events.value = data.map((item) => EventModel.fromJson(item)).toList();
        LoggerUtility.info("Loaded ${events.length} events from backend.");
      } else {
        LoggerUtility.error("Failed to load events: ${response.statusCode}");
        _loadFallbackData();
      }
    } catch (e) {
      LoggerUtility.error("Network error fetching events, loading fallback data", e);
      // Fallback to local sample events if backend server is not running locally
      if (events.isEmpty) {
        _loadFallbackData();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates a new event (`POST /events`).
  Future<void> createEvent({
    required String title,
    String? description,
    String? eventDate,
    String? eventLocation,
  }) async {
    if (title.trim().isEmpty) {
      AppSnackbar.error(title: "Invalid Input", message: "Event title cannot be empty");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _eventService.createEvent(
        title: title.trim(),
        description: description?.trim(),
        eventDate: eventDate?.trim(),
        eventLocation: eventLocation?.trim(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final newEvent = EventModel.fromJson(data);
        events.insert(0, newEvent);
        AppSnackbar.success(title: "Event Created", message: "Successfully created '$title'!");
      } else {
        AppSnackbar.error(title: "Creation Failed", message: "Server returned status ${response.statusCode}");
      }
    } catch (e) {
      LoggerUtility.error("Error creating event online, creating locally for offline preview", e);
      // Offline fallback behavior
      final localEvent = EventModel(
        evntId: DateTime.now().millisecondsSinceEpoch.toString(),
        eventTitle: title.trim(),
        description: description?.trim(),
        eventDate: eventDate?.trim(),
        eventLocation: eventLocation?.trim(),
        createdAt: DateTime.now(),
      );
      events.insert(0, localEvent);
      AppSnackbar.info(title: "Offline Mode", message: "Created event locally.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates an existing event (`PUT /events/{id}`).
  Future<void> updateEvent(
    String id, {
    required String title,
    String? description,
    String? eventDate,
    String? eventLocation,
  }) async {
    if (title.trim().isEmpty) {
      AppSnackbar.error(title: "Invalid Input", message: "Event title cannot be empty");
      return;
    }

    isLoading.value = true;
    try {
      final response = await _eventService.updateEvent(
        id,
        title: title.trim(),
        description: description?.trim(),
        eventDate: eventDate?.trim(),
        eventLocation: eventLocation?.trim(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final updatedEvent = EventModel.fromJson(data);
        final index = events.indexWhere((e) => e.id == id);
        if (index != -1) {
          events[index] = updatedEvent;
        }
        AppSnackbar.success(title: "Event Updated", message: "Successfully updated '$title'!");
      } else {
        AppSnackbar.error(title: "Update Failed", message: "Server returned status ${response.statusCode}");
      }
    } catch (e) {
      LoggerUtility.error("Error updating event online, updating locally", e);
      // Offline fallback behavior
      final index = events.indexWhere((e) => e.id == id);
      if (index != -1) {
        events[index] = events[index].copyWith(
          eventTitle: title.trim(),
          description: description?.trim(),
          eventDate: eventDate?.trim(),
          eventLocation: eventLocation?.trim(),
          updatedAt: DateTime.now(),
        );
      }
      AppSnackbar.info(title: "Offline Mode", message: "Updated event locally.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes an event (`DELETE /events/{id}`).
  Future<void> deleteEvent(String id) async {
    try {
      final response = await _eventService.deleteEvent(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        events.removeWhere((e) => e.id == id);
        AppSnackbar.success(title: "Event Deleted", message: "Event removed successfully");
      } else {
        AppSnackbar.error(title: "Delete Failed", message: "Server returned status ${response.statusCode}");
      }
    } catch (e) {
      LoggerUtility.error("Error deleting event online, removing locally", e);
      // Offline fallback removal
      events.removeWhere((e) => e.id == id);
      AppSnackbar.info(title: "Offline Mode", message: "Deleted event locally.");
    }
  }

  // Calculated Stats for Dashboard summary cards
  int get totalEvents => events.length;

  int get totalImages => events.fold(0, (sum, event) => sum + event.imageCount);

  double get totalStorageMb =>
      events.fold(0.0, (sum, event) => sum + event.sizeInMb);

  String get formattedTotalStorage {
    if (totalStorageMb > 1024) {
      return '${(totalStorageMb / 1024).toStringAsFixed(2)} GB';
    }
    return '${totalStorageMb.toStringAsFixed(1)} MB';
  }

  /// Loads initial fallback mock data if backend is offline or empty.
  void _loadFallbackData() {
    events.assignAll([
      EventModel(
        evntId: '1',
        eventTitle: 'Wedding Anniversary',
        description: 'Celebrating 10 wonderful years together with family and friends.',
        eventLocation: 'Goa Beach Resort',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        imageCount: 124,
        sizeInMb: 450.5,
      ),
      EventModel(
        evntId: '2',
        eventTitle: 'Beach Trip 2024',
        description: 'Weekend getaway to the coast with college buddies.',
        eventLocation: 'Pondicherry',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        imageCount: 85,
        sizeInMb: 320.0,
      ),
      EventModel(
        evntId: '3',
        eventTitle: 'Birthday Party',
        description: 'Surprise 30th birthday celebration at downtown rooftop.',
        eventLocation: 'Bangalore',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        imageCount: 210,
        sizeInMb: 890.2,
      ),
      EventModel(
        evntId: '4',
        eventTitle: 'Corporate Meetup',
        description: 'Annual tech leadership conference and networking event.',
        eventLocation: 'Hyderabad IT Park',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        imageCount: 45,
        sizeInMb: 150.8,
      ),
    ]);
  }
}

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
/// 3. Errors from the backend or network are surfaced to the user via snackbars —
///    no silent fallback data, so real failures are never masked.
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
        AppSnackbar.error(
          title: "Load Failed",
          message: "Server returned status ${response.statusCode}.",
        );
      }
    } catch (e, st) {
      LoggerUtility.error("Network error fetching events", e, st);
      AppSnackbar.error(
        title: "Network Error",
        message: "Could not reach the server. Check your connection.",
      );
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
    } catch (e, st) {
      LoggerUtility.error("Error creating event", e, st);
      AppSnackbar.error(
        title: "Creation Failed",
        message: "Could not reach the server. Event was not created.",
      );
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
    } catch (e, st) {
      LoggerUtility.error("Error updating event", e, st);
      AppSnackbar.error(
        title: "Update Failed",
        message: "Could not reach the server. Event was not updated.",
      );
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
    } catch (e, st) {
      LoggerUtility.error("Error deleting event", e, st);
      AppSnackbar.error(
        title: "Delete Failed",
        message: "Could not reach the server. Event was not deleted.",
      );
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
}

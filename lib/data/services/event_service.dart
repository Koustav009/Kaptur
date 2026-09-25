import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'api_constants.dart';

/// This service handles all HTTP network requests related to Events.
///
/// NOTE FOR LEARNERS:
/// 1. Creating: `POST /events` sends new event data as JSON.
/// 2. Reading: `GET /events` gets all events created by the logged-in user.
/// 3. Updating: `PUT /events/{id}` updates the title, description, or date of an existing event.
/// 4. Deleting: `DELETE /events/{id}` tells the backend to remove (soft-delete) the event.
class EventService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches all events belonging to the currently logged-in user (`GET /events`).
  Future<http.Response> getEvents() async {
    return _apiClient.get(ApiConstants.eventsPath);
  }

  /// Fetches details for a single specific event (`GET /events/{id}`).
  Future<http.Response> getEventById(String id) async {
    return _apiClient.get('${ApiConstants.eventsPath}/$id');
  }

  /// Creates a new event (`POST /events`).
  /// Backend expects JSON matching `EventRequest`: `eventTitle`, `description`, `eventDate`, `eventLocation`.
  Future<http.Response> createEvent({
    required String title,
    String? description,
    String? eventDate,
    String? eventLocation,
  }) async {
    return _apiClient.post(
      ApiConstants.eventsPath,
      body: {
        'eventTitle': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (eventDate != null && eventDate.isNotEmpty) 'eventDate': eventDate,
        if (eventLocation != null && eventLocation.isNotEmpty)
          'eventLocation': eventLocation,
      },
    );
  }

  /// Updates an existing event (`PUT /events/{id}`).
  Future<http.Response> updateEvent(
    String id, {
    required String title,
    String? description,
    String? eventDate,
    String? eventLocation,
  }) async {
    return _apiClient.put(
      '${ApiConstants.eventsPath}/$id',
      body: {
        'eventTitle': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (eventDate != null && eventDate.isNotEmpty) 'eventDate': eventDate,
        if (eventLocation != null && eventLocation.isNotEmpty)
          'eventLocation': eventLocation,
      },
    );
  }

  /// Soft-deletes an event (`DELETE /events/{id}`).
  Future<http.Response> deleteEvent(String id) async {
    return _apiClient.delete('${ApiConstants.eventsPath}/$id');
  }
}

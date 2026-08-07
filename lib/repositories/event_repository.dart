import '../models/event_model.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService _eventService;

  EventRepository({
    EventService? eventService,
  }) : _eventService = eventService ?? EventService();

  /// Alle Events live laden
  Stream<List<EventModel>> watchEvents() {
    return _eventService.watchEvents();
  }

  /// Nur aktive Events live laden
  Stream<List<EventModel>> watchActiveEvents() {
    return _eventService.watchActiveEvents();
  }

  /// Einzelnes Event einmal laden
  Future<EventModel?> getEvent(
    String eventId,
  ) {
    return _eventService.getEvent(eventId);
  }

  /// Einzelnes Event live beobachten
  Stream<EventModel?> watchEvent(
    String eventId,
  ) {
    return _eventService.watchEvent(eventId);
  }

  /// Event speichern
  Future<void> saveEvent(
    EventModel event,
  ) {
    return _eventService.saveEvent(event);
  }

  /// Event löschen
  Future<void> deleteEvent(
    String eventId,
  ) {
    return _eventService.deleteEvent(eventId);
  }

  /// Event aktivieren/deaktivieren
  Future<void> setEventActive({
    required String eventId,
    required bool active,
  }) {
    return _eventService.setEventActive(
      eventId: eventId,
      active: active,
    );
  }

  /// Anmeldung öffnen/schließen
  Future<void> setRegistrationOpen({
    required String eventId,
    required bool open,
  }) {
    return _eventService.setRegistrationOpen(
      eventId: eventId,
      open: open,
    );
  }

  /// Startzeit ändern
  Future<void> setStartTime({
    required String eventId,
    required String startTime,
  }) {
    return _eventService.setStartTime(
      eventId: eventId,
      startTime: startTime,
    );
  }

  /// Events eines bestimmten Typs laden
  Stream<List<EventModel>> watchEventsByType(
    String eventType,
  ) {
    return _eventService.watchEventsByType(
      eventType,
    );
  }
}
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventRepository {
  final EventService _eventService;

  EventRepository({
    EventService? eventService,
  }) : _eventService =
            eventService ?? EventService();

  Stream<List<EventModel>> watchEvents() {
    return _eventService.watchEvents();
  }

  Stream<List<EventModel>> watchActiveEvents() {
    return _eventService.watchActiveEvents();
  }

  Future<EventModel?> getEvent(
    String eventId,
  ) {
    return _eventService.getEvent(
      eventId,
    );
  }

  Stream<EventModel?> watchEvent(
    String eventId,
  ) {
    return _eventService.watchEvent(
      eventId,
    );
  }

  Future<void> saveEvent(
    EventModel event,
  ) {
    return _eventService.saveEvent(
      event,
    );
  }

  Future<void> deleteEvent(
    String eventId,
  ) {
    return _eventService.deleteEvent(
      eventId,
    );
  }

  Future<void> setEventActive({
    required String eventId,
    required bool active,
  }) {
    return _eventService.setEventActive(
      eventId: eventId,
      active: active,
    );
  }

  Future<void> setRegistrationOpen({
    required String eventId,
    required bool open,
  }) {
    return _eventService.setRegistrationOpen(
      eventId: eventId,
      open: open,
    );
  }

  Future<void> setStartTime({
    required String eventId,
    required String startTime,
  }) {
    return _eventService.setStartTime(
      eventId: eventId,
      startTime: startTime,
    );
  }

  Stream<List<EventModel>> watchEventsByType(
    String eventType,
  ) {
    return _eventService.watchEventsByType(
      eventType,
    );
  }
}
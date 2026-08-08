import '../models/event_registration_model.dart';
import '../services/event_registration_service.dart';

class RegistrationRepository {
  final EventRegistrationService _registrationService;

  RegistrationRepository({
    EventRegistrationService? registrationService,
  }) : _registrationService =
            registrationService ?? EventRegistrationService();

  Future<void> saveRegistration(
    EventRegistrationModel registration,
  ) {
    return _registrationService.saveRegistration(
      registration,
    );
  }

  Future<EventRegistrationModel?> getRegistration({
    required String eventId,
    required String userId,
  }) {
    return _registrationService.getRegistration(
      eventId: eventId,
      userId: userId,
    );
  }

  Stream<List<EventRegistrationModel>> watchRegistrations(
    String eventId,
  ) {
    return _registrationService.watchRegistrations(
      eventId,
    );
  }

  Stream<List<EventRegistrationModel>> watchBySelection({
    required String eventId,
    required String selection,
  }) {
    return _registrationService.watchBySelection(
      eventId: eventId,
      selection: selection,
    );
  }

  Future<void> changeSelection({
    required String eventId,
    required String userId,
    required String selection,
  }) {
    return _registrationService.changeSelection(
      eventId: eventId,
      userId: userId,
      selection: selection,
    );
  }

  Future<void> deleteRegistration({
    required String eventId,
    required String userId,
  }) {
    return _registrationService.deleteRegistration(
      eventId: eventId,
      userId: userId,
    );
  }

  Future<int> countBySelection({
    required String eventId,
    required String selection,
  }) {
    return _registrationService.countBySelection(
      eventId: eventId,
      selection: selection,
    );
  }
}
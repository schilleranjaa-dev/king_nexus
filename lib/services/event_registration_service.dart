import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_registration_model.dart';

class EventRegistrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _registrationsRef(
    String eventId,
  ) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('registrations');
  }

  /// Anmeldung speichern oder aktualisieren
  Future<void> saveRegistration(
    EventRegistrationModel registration,
  ) async {
    await _registrationsRef(registration.eventId)
        .doc(registration.userId)
        .set(
          registration.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Eigene Anmeldung laden
  Future<EventRegistrationModel?> getRegistration({
    required String eventId,
    required String userId,
  }) async {
    final doc = await _registrationsRef(eventId).doc(userId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return EventRegistrationModel.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  /// Alle Anmeldungen eines Events live laden
  Stream<List<EventRegistrationModel>> watchRegistrations(
    String eventId,
  ) {
    return _registrationsRef(eventId)
        .orderBy('playerName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EventRegistrationModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// Eigene Anmeldung löschen
  Future<void> deleteRegistration({
    required String eventId,
    required String userId,
  }) async {
    await _registrationsRef(eventId).doc(userId).delete();
  }

  /// Nur Teilnehmer einer bestimmten Auswahl live laden
  Stream<List<EventRegistrationModel>> watchBySelection({
    required String eventId,
    required String selection,
  }) {
    return _registrationsRef(eventId)
        .where(
          'selection',
          isEqualTo: selection,
        )
        .orderBy('playerName')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EventRegistrationModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}
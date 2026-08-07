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

  Future<void> saveRegistration(
    EventRegistrationModel registration,
  ) async {
    await _registrationsRef(
      registration.eventId,
    ).doc(
      registration.userId,
    ).set(
      registration.toMap(),
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<EventRegistrationModel?> getRegistration({
    required String eventId,
    required String userId,
  }) async {
    final doc = await _registrationsRef(
      eventId,
    ).doc(
      userId,
    ).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return EventRegistrationModel.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  Stream<List<EventRegistrationModel>> watchRegistrations(
    String eventId,
  ) {
    return _registrationsRef(
      eventId,
    ).snapshots().map(
      (snapshot) {
        final registrations = snapshot.docs.map(
          (doc) {
            return EventRegistrationModel.fromMap(
              doc.id,
              doc.data(),
            );
          },
        ).toList();

        registrations.sort(
          (a, b) => a.playerName
              .toLowerCase()
              .compareTo(
                b.playerName.toLowerCase(),
              ),
        );

        return registrations;
      },
    );
  }

  Stream<List<EventRegistrationModel>> watchBySelection({
    required String eventId,
    required String selection,
  }) {
    return _registrationsRef(
      eventId,
    )
        .where(
          'selection',
          isEqualTo: selection,
        )
        .snapshots()
        .map(
          (snapshot) {
            final registrations = snapshot.docs.map(
              (doc) {
                return EventRegistrationModel.fromMap(
                  doc.id,
                  doc.data(),
                );
              },
            ).toList();

            registrations.sort(
              (a, b) => a.playerName
                  .toLowerCase()
                  .compareTo(
                    b.playerName.toLowerCase(),
                  ),
            );

            return registrations;
          },
        );
  }

  Future<void> changeSelection({
    required String eventId,
    required String userId,
    required String selection,
  }) async {
    await _registrationsRef(
      eventId,
    ).doc(
      userId,
    ).update({
      'selection': selection,
      'updatedAt':
          DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteRegistration({
    required String eventId,
    required String userId,
  }) async {
    await _registrationsRef(
      eventId,
    ).doc(
      userId,
    ).delete();
  }

  Future<int> countBySelection({
    required String eventId,
    required String selection,
  }) async {
    final snapshot = await _registrationsRef(
      eventId,
    )
        .where(
          'selection',
          isEqualTo: selection,
        )
        .get();

    return snapshot.docs.length;
  }
}
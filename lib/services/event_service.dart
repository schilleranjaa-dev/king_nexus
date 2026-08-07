import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _eventsRef {
    return _firestore.collection('events');
  }

  /// Alle Events live laden
  Stream<List<EventModel>> watchEvents() {
    return _eventsRef.snapshots().map(
      (snapshot) {
        final events = snapshot.docs.map(
          (doc) {
            return EventModel.fromMap({
              'id': doc.id,
              ...doc.data(),
            });
          },
        ).toList();

        events.sort(
          (a, b) => a.title
              .toLowerCase()
              .compareTo(
                b.title.toLowerCase(),
              ),
        );

        return events;
      },
    );
  }

  /// Nur aktive Events live laden
  Stream<List<EventModel>> watchActiveEvents() {
    return _eventsRef
        .where(
          'isActive',
          isEqualTo: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            final events = snapshot.docs.map(
              (doc) {
                return EventModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                });
              },
            ).toList();

            events.sort(
              (a, b) => a.title
                  .toLowerCase()
                  .compareTo(
                    b.title.toLowerCase(),
                  ),
            );

            return events;
          },
        );
  }

  /// Einzelnes Event laden
  Future<EventModel?> getEvent(
    String eventId,
  ) async {
    final doc =
        await _eventsRef.doc(eventId).get();

    if (!doc.exists ||
        doc.data() == null) {
      return null;
    }

    return EventModel.fromMap({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  /// Einzelnes Event live beobachten
  Stream<EventModel?> watchEvent(
    String eventId,
  ) {
    return _eventsRef
        .doc(eventId)
        .snapshots()
        .map(
          (doc) {
            if (!doc.exists ||
                doc.data() == null) {
              return null;
            }

            return EventModel.fromMap({
              'id': doc.id,
              ...doc.data()!,
            });
          },
        );
  }

  /// Neues Event erstellen oder vorhandenes ersetzen
  Future<void> saveEvent(
    EventModel event,
  ) async {
    await _eventsRef
        .doc(event.id)
        .set(
          event.toMap(),
          SetOptions(
            merge: true,
          ),
        );
  }

  /// Event löschen
  Future<void> deleteEvent(
    String eventId,
  ) async {
    await _eventsRef
        .doc(eventId)
        .delete();
  }

  /// Event aktivieren oder deaktivieren
  Future<void> setEventActive({
    required String eventId,
    required bool active,
  }) async {
    await _eventsRef
        .doc(eventId)
        .update({
      'isActive': active,
    });
  }

  /// Anmeldung öffnen oder schließen
  Future<void> setRegistrationOpen({
    required String eventId,
    required bool open,
  }) async {
    await _eventsRef
        .doc(eventId)
        .update({
      'registrationOpen': open,
    });
  }

  /// Event-Zeit ändern
  Future<void> setStartTime({
    required String eventId,
    required String startTime,
  }) async {
    await _eventsRef
        .doc(eventId)
        .update({
      'startTime': startTime,
    });
  }

  /// Alle Events eines bestimmten Typs laden
  Stream<List<EventModel>> watchEventsByType(
    String eventType,
  ) {
    return _eventsRef
        .where(
          'eventType',
          isEqualTo: eventType,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs.map(
              (doc) {
                return EventModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                });
              },
            ).toList();
          },
        );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_group_model.dart';

class EventGroupService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      _groupsRef(
    String eventId,
  ) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('groups');
  }

  Future<void> saveGroup({
    required String eventId,
    required EventGroupModel group,
  }) async {
    await _groupsRef(eventId)
        .doc(group.id)
        .set(
          group.toMap(),
          SetOptions(
            merge: true,
          ),
        );
  }

  Future<void> saveGroups({
    required String eventId,
    required List<EventGroupModel> groups,
  }) async {
    final batch = _firestore.batch();

    for (final group in groups) {
      final ref =
          _groupsRef(eventId)
              .doc(group.id);

      batch.set(
        ref,
        group.toMap(),
        SetOptions(
          merge: true,
        ),
      );
    }

    await batch.commit();
  }

  Future<EventGroupModel?> getGroup({
    required String eventId,
    required String groupId,
  }) async {
    final doc =
        await _groupsRef(eventId)
            .doc(groupId)
            .get();

    if (!doc.exists ||
        doc.data() == null) {
      return null;
    }

    return EventGroupModel.fromMap({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  Stream<EventGroupModel?> watchGroup({
    required String eventId,
    required String groupId,
  }) {
    return _groupsRef(eventId)
        .doc(groupId)
        .snapshots()
        .map(
          (doc) {
            if (!doc.exists ||
                doc.data() == null) {
              return null;
            }

            return EventGroupModel.fromMap({
              'id': doc.id,
              ...doc.data()!,
            });
          },
        );
  }

  Stream<List<EventGroupModel>>
      watchGroups(
    String eventId,
  ) {
    return _groupsRef(eventId)
        .snapshots()
        .map(
          (snapshot) {
            final groups =
                snapshot.docs
                    .map(
                      (doc) =>
                          EventGroupModel.fromMap({
                        'id': doc.id,
                        ...doc.data(),
                      }),
                    )
                    .toList();

            groups.sort(
              (a, b) =>
                  a.sortOrder.compareTo(
                b.sortOrder,
              ),
            );

            return groups;
          },
        );
  }

  Future<void> deleteGroup({
    required String eventId,
    required String groupId,
  }) async {
    await _groupsRef(eventId)
        .doc(groupId)
        .delete();
  }

  Future<void> setGroupDateTime({
    required String eventId,
    required String groupId,
    required DateTime dateTime,
  }) async {
    await _groupsRef(eventId)
        .doc(groupId)
        .update({
      'eventDateTime':
          dateTime
              .toUtc()
              .toIso8601String(),
    });
  }

  Future<void> setInheritsTimeFrom({
    required String eventId,
    required String groupId,
    String? inheritsTimeFrom,
  }) async {
    await _groupsRef(eventId)
        .doc(groupId)
        .update({
      'inheritsTimeFrom':
          inheritsTimeFrom,
    });
  }
}
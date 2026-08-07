import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _profileRef(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  Future<void> saveProfile(UserModel user) async {
    await _profileRef(user.id).set(
      user.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<UserModel?> loadProfile(String userId) async {
    final doc = await _profileRef(userId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromMap({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  Stream<UserModel?> watchProfile(String userId) {
    return _profileRef(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromMap({
        'id': doc.id,
        ...doc.data()!,
      });
    });
  }

  Future<void> deleteProfile(String userId) async {
    await _profileRef(userId).delete();
  }
}
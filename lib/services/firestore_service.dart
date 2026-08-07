import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Bear Trap 1 speichern
  Future<void> saveBearTrap1Time(String time) async {
    await _db.collection('settings').doc('beartrap1').set({
      'time': time,
    });
  }

  /// Bear Trap 2 speichern
  Future<void> saveBearTrap2Time(String time) async {
    await _db.collection('settings').doc('beartrap2').set({
      'time': time,
    });
  }

  /// Bear Trap 1 laden
  Future<String> loadBearTrap1Time() async {
    final doc = await _db.collection('settings').doc('beartrap1').get();

    if (!doc.exists) {
      return "19:30 UTC";
    }

    return doc.data()?['time'] ?? "19:30 UTC";
  }

  /// Bear Trap 2 laden
  Future<String> loadBearTrap2Time() async {
    final doc = await _db.collection('settings').doc('beartrap2').get();

    if (!doc.exists) {
      return "14:00 UTC";
    }

    return doc.data()?['time'] ?? "14:00 UTC";
  }
}
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const String _userIdKey = 'king_nexus_user_id';

  final Uuid _uuid = const Uuid();

  Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();

    final existingUserId = prefs.getString(_userIdKey);

    if (existingUserId != null && existingUserId.isNotEmpty) {
      return existingUserId;
    }

    final newUserId = _uuid.v4();

    await prefs.setString(
      _userIdKey,
      newUserId,
    );

    return newUserId;
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userIdKey);
  }

  Future<void> resetUserId() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
  }
}
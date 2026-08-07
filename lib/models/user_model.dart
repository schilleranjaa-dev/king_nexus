class UserModel {
  final String id;
  final String playerName;
  final String alliance;
  final String role;
  final String discordName;
  final int furnaceLevel;
  final bool isAdmin;

  const UserModel({
    required this.id,
    required this.playerName,
    required this.alliance,
    required this.role,
    required this.discordName,
    required this.furnaceLevel,
    required this.isAdmin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      playerName: map['playerName']?.toString() ?? '',
      alliance: map['alliance']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Member',
      discordName: map['discordName']?.toString() ?? '',
      furnaceLevel: _parseInt(map['furnaceLevel']),
      isAdmin: _parseBool(map['isAdmin']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase().trim() == 'true';
    }

    if (value is num) {
      return value != 0;
    }

    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerName': playerName,
      'alliance': alliance,
      'role': role,
      'discordName': discordName,
      'furnaceLevel': furnaceLevel,
      'isAdmin': isAdmin,
    };
  }

  UserModel copyWith({
    String? id,
    String? playerName,
    String? alliance,
    String? role,
    String? discordName,
    int? furnaceLevel,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      alliance: alliance ?? this.alliance,
      role: role ?? this.role,
      discordName: discordName ?? this.discordName,
      furnaceLevel: furnaceLevel ?? this.furnaceLevel,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
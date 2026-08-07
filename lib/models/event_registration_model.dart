class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String playerName;
  final String alliance;
  final String role;
  final String selection;
  final DateTime updatedAt;

  const EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.playerName,
    required this.alliance,
    required this.role,
    required this.selection,
    required this.updatedAt,
  });

  factory EventRegistrationModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return EventRegistrationModel(
      id: id,
      eventId: map['eventId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      playerName: map['playerName']?.toString() ?? '',
      alliance: map['alliance']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Member',
      selection: map['selection']?.toString() ?? '',
      updatedAt: _parseDateTime(
        map['updatedAt'],
      ),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is DateTime) {
      return value;
    }

    final parsed = DateTime.tryParse(
      value.toString(),
    );

    return parsed ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'playerName': playerName,
      'alliance': alliance,
      'role': role,
      'selection': selection,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  EventRegistrationModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? playerName,
    String? alliance,
    String? role,
    String? selection,
    DateTime? updatedAt,
  }) {
    return EventRegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      playerName: playerName ?? this.playerName,
      alliance: alliance ?? this.alliance,
      role: role ?? this.role,
      selection: selection ?? this.selection,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
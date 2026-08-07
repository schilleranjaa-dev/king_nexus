class EventRegistrationModel {
  final String id;
  final String eventId;
  final String userId;
  final String playerName;
  final String alliance;
  final String selection;
  final DateTime updatedAt;

  const EventRegistrationModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.playerName,
    required this.alliance,
    required this.selection,
    required this.updatedAt,
  });

  factory EventRegistrationModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return EventRegistrationModel(
      id: id,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      playerName: map['playerName'] ?? '',
      alliance: map['alliance'] ?? '',
      selection: map['selection'] ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'playerName': playerName,
      'alliance': alliance,
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
    String? selection,
    DateTime? updatedAt,
  }) {
    return EventRegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      playerName: playerName ?? this.playerName,
      alliance: alliance ?? this.alliance,
      selection: selection ?? this.selection,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
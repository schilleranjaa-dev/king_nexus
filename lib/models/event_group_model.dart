class EventGroupModel {
  final String id;
  final String name;
  final String description;

  final int maxPlayers;
  final bool allowsRegistration;
  final int sortOrder;

  /// Eigener Termin dieser Gruppe.
  /// Beispiel:
  /// Legion 1 -> 08.08.2026 19:30 UTC
  final DateTime? eventDateTime;

  /// Optional:
  /// Diese Gruppe übernimmt den Termin
  /// einer anderen Gruppe.
  ///
  /// Beispiel:
  /// reserve_legion1 -> legion1
  final String? inheritsTimeFrom;

  const EventGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxPlayers,
    required this.allowsRegistration,
    required this.sortOrder,
    this.eventDateTime,
    this.inheritsTimeFrom,
  });

  factory EventGroupModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return EventGroupModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      maxPlayers: _parseInt(
        map['maxPlayers'],
      ),
      allowsRegistration: _parseBool(
        map['allowsRegistration'],
      ),
      sortOrder: _parseInt(
        map['sortOrder'],
      ),
      eventDateTime: _parseDateTime(
        map['eventDateTime'],
      ),
      inheritsTimeFrom:
          map['inheritsTimeFrom']
                  ?.toString()
                  .trim()
                  .isEmpty ==
              true
          ? null
          : map['inheritsTimeFrom']?.toString(),
    );
  }

  static int _parseInt(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
            value.trim(),
          ) ??
          0;
    }

    return 0;
  }

  static bool _parseBool(
    dynamic value,
  ) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final normalized =
          value.trim().toLowerCase();

      if (normalized == 'true') {
        return true;
      }

      if (normalized == 'false') {
        return false;
      }
    }

    return false;
  }

  static DateTime? _parseDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toUtc();
    }

    final parsed = DateTime.tryParse(
      value.toString(),
    );

    return parsed?.toUtc();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'maxPlayers': maxPlayers,
      'allowsRegistration':
          allowsRegistration,
      'sortOrder': sortOrder,
      'eventDateTime':
          eventDateTime
              ?.toUtc()
              .toIso8601String(),
      'inheritsTimeFrom':
          inheritsTimeFrom,
    };
  }

  EventGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    int? maxPlayers,
    bool? allowsRegistration,
    int? sortOrder,
    DateTime? eventDateTime,
    String? inheritsTimeFrom,
  }) {
    return EventGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description ?? this.description,
      maxPlayers:
          maxPlayers ?? this.maxPlayers,
      allowsRegistration:
          allowsRegistration ??
              this.allowsRegistration,
      sortOrder:
          sortOrder ?? this.sortOrder,
      eventDateTime:
          eventDateTime ??
              this.eventDateTime,
      inheritsTimeFrom:
          inheritsTimeFrom ??
              this.inheritsTimeFrom,
    );
  }
}
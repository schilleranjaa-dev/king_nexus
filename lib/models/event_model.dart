class EventModel {
  final String id;
  final String title;
  final String description;

  /// Bleibt vorerst für ältere Bereiche der App erhalten.
  final String startTime;

  /// Optionaler allgemeiner Termin für Events,
  /// die nur einen einzigen Termin besitzen.
  final DateTime? eventDateTime;

  final String eventType;

  final bool isActive;
  final bool registrationOpen;

  final bool hasGroups;
  final bool hasTeams;
  final bool hasGuide;
  final bool hasCountdown;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.eventDateTime,
    required this.eventType,
    required this.isActive,
    required this.registrationOpen,
    required this.hasGroups,
    required this.hasTeams,
    required this.hasGuide,
    required this.hasCountdown,
  });

  factory EventModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return EventModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      startTime:
          map['startTime']?.toString() ?? '',
      eventDateTime: _parseDateTime(
        map['eventDateTime'],
      ),
      eventType:
          map['eventType']?.toString() ?? '',
      isActive: _parseBool(
        map['isActive'],
        fallback: true,
      ),
      registrationOpen: _parseBool(
        map['registrationOpen'],
        fallback: true,
      ),
      hasGroups: _parseBool(
        map['hasGroups'],
      ),
      hasTeams: _parseBool(
        map['hasTeams'],
      ),
      hasGuide: _parseBool(
        map['hasGuide'],
        fallback: true,
      ),
      hasCountdown: _parseBool(
        map['hasCountdown'],
        fallback: true,
      ),
    );
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

  static bool _parseBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value == null) {
      return fallback;
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

    return fallback;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'eventDateTime':
          eventDateTime
              ?.toUtc()
              .toIso8601String(),
      'eventType': eventType,
      'isActive': isActive,
      'registrationOpen':
          registrationOpen,
      'hasGroups': hasGroups,
      'hasTeams': hasTeams,
      'hasGuide': hasGuide,
      'hasCountdown': hasCountdown,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? startTime,
    DateTime? eventDateTime,
    String? eventType,
    bool? isActive,
    bool? registrationOpen,
    bool? hasGroups,
    bool? hasTeams,
    bool? hasGuide,
    bool? hasCountdown,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          description ?? this.description,
      startTime:
          startTime ?? this.startTime,
      eventDateTime:
          eventDateTime ??
              this.eventDateTime,
      eventType:
          eventType ?? this.eventType,
      isActive:
          isActive ?? this.isActive,
      registrationOpen:
          registrationOpen ??
              this.registrationOpen,
      hasGroups:
          hasGroups ?? this.hasGroups,
      hasTeams:
          hasTeams ?? this.hasTeams,
      hasGuide:
          hasGuide ?? this.hasGuide,
      hasCountdown:
          hasCountdown ??
              this.hasCountdown,
    );
  }
}
import 'event_group_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String startTime;
  final String eventType;
  final bool isActive;
  final bool registrationOpen;

  final bool hasGroups;
  final bool hasTeams;
  final bool hasGuide;
  final bool hasCountdown;

  final List<EventGroupModel> groups;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.eventType,
    required this.isActive,
    required this.registrationOpen,
    required this.hasGroups,
    required this.hasTeams,
    required this.hasGuide,
    required this.hasCountdown,
    required this.groups,
  });

  factory EventModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final rawGroups = map['groups'];

    List<EventGroupModel> parsedGroups = [];

    if (rawGroups is List) {
      parsedGroups = rawGroups
          .whereType<Map>()
          .map(
            (group) => EventGroupModel.fromMap(
              Map<String, dynamic>.from(group),
            ),
          )
          .toList();

      parsedGroups.sort(
        (a, b) => a.sortOrder.compareTo(
          b.sortOrder,
        ),
      );
    }

    return EventModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description:
          map['description']?.toString() ?? '',
      startTime:
          map['startTime']?.toString() ?? '',
      eventType:
          map['eventType']?.toString() ?? '',
      isActive: _parseBool(
        map['isActive'],
        fallback: true,
      ),
      registrationOpen: _parseBool(
        map['registrationOpen'],
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
      groups: parsedGroups,
    );
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

    if (value is num) {
      return value != 0;
    }

    return fallback;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'eventType': eventType,
      'isActive': isActive,
      'registrationOpen':
          registrationOpen,
      'hasGroups': hasGroups,
      'hasTeams': hasTeams,
      'hasGuide': hasGuide,
      'hasCountdown': hasCountdown,
      'groups': groups
          .map(
            (group) => group.toMap(),
          )
          .toList(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? startTime,
    String? eventType,
    bool? isActive,
    bool? registrationOpen,
    bool? hasGroups,
    bool? hasTeams,
    bool? hasGuide,
    bool? hasCountdown,
    List<EventGroupModel>? groups,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          description ?? this.description,
      startTime:
          startTime ?? this.startTime,
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
      groups: groups ?? this.groups,
    );
  }
}
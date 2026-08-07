class EventGroupModel {
  final String id;
  final String name;
  final String description;
  final int maxPlayers;
  final bool allowsRegistration;
  final int sortOrder;

  const EventGroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxPlayers,
    required this.allowsRegistration,
    required this.sortOrder,
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
      allowsRegistration:
          _parseBool(
        map['allowsRegistration'],
      ),
      sortOrder: _parseInt(
        map['sortOrder'],
      ),
    );
  }

  static int _parseInt(dynamic value) {
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

  static bool _parseBool(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value
          .trim()
          .toLowerCase() ==
          'true';
    }

    if (value is num) {
      return value != 0;
    }

    return false;
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
    };
  }

  EventGroupModel copyWith({
    String? id,
    String? name,
    String? description,
    int? maxPlayers,
    bool? allowsRegistration,
    int? sortOrder,
  }) {
    return EventGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description ??
              this.description,
      maxPlayers:
          maxPlayers ??
              this.maxPlayers,
      allowsRegistration:
          allowsRegistration ??
              this.allowsRegistration,
      sortOrder:
          sortOrder ??
              this.sortOrder,
    );
  }
}
import 'package:flutter/material.dart';

import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../models/event_registration_model.dart';
import '../models/user_model.dart';
import '../repositories/event_group_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/registration_repository.dart';
import '../services/device_service.dart';
import '../services/profile_service.dart';

class SwordlandController extends ChangeNotifier {
  final EventRepository eventRepository;
  final EventGroupRepository groupRepository;
  final RegistrationRepository registrationRepository;
  final DeviceService deviceService;
  final ProfileService profileService;

  SwordlandController({
    EventRepository? eventRepository,
    EventGroupRepository? groupRepository,
    RegistrationRepository? registrationRepository,
    DeviceService? deviceService,
    ProfileService? profileService,
  })  : eventRepository =
            eventRepository ?? EventRepository(),
        groupRepository =
            groupRepository ?? EventGroupRepository(),
        registrationRepository =
            registrationRepository ??
                RegistrationRepository(),
        deviceService =
            deviceService ?? DeviceService(),
        profileService =
            profileService ?? ProfileService();

  static const String eventId = 'swordland';

  String? userId;
  UserModel? currentUser;
  String? mySelection;

  bool isLoading = true;
  bool isSavingSelection = false;
  bool isSavingDateTime = false;

  bool get canEditEvent {
    return currentUser?.role == 'R4' ||
        currentUser?.role == 'R5';
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      await _ensureSwordlandExists();
      await _ensureSwordlandGroupsExist();

      final id =
          await deviceService.getOrCreateUserId();

      final profile =
          await profileService.loadProfile(id);

      final registration =
          await registrationRepository
              .getRegistration(
        eventId: eventId,
        userId: id,
      );

      userId = id;
      currentUser = profile;
      mySelection = registration?.selection;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureSwordlandExists() async {
    final existing =
        await eventRepository.getEvent(eventId);

    if (existing != null) {
      return;
    }

    const event = EventModel(
      id: eventId,
      title: 'Swordland',
      description:
          'Legionen, Ersatzspieler, Teams und Strategie.',
      startTime: '19:30 UTC',
      eventType: 'swordland',
      isActive: true,
      registrationOpen: true,
      hasGroups: true,
      hasTeams: true,
      hasGuide: true,
      hasCountdown: true,
    );

    await eventRepository.saveEvent(event);
  }

  Future<void> _ensureSwordlandGroupsExist() async {
    final existingGroups =
        await groupRepository
            .watchGroups(eventId)
            .first;

    final groupsById = {
      for (final group in existingGroups)
        group.id: group,
    };

    final desiredGroups =
        <EventGroupModel>[
      EventGroupModel(
        id: 'legion1',
        name: 'Legion 1',
        description:
            'Feste Teilnahme in Legion 1',
        maxPlayers: 30,
        allowsRegistration: true,
        sortOrder: 1,
        eventDateTime:
            groupsById['legion1']
                ?.eventDateTime,
      ),
      EventGroupModel(
        id: 'reserve_legion1',
        name: 'Ersatz Legion 1',
        description:
            'Als Ersatz für Legion 1 verfügbar',
        maxPlayers: 10,
        allowsRegistration: true,
        sortOrder: 2,
        inheritsTimeFrom: 'legion1',
      ),
      EventGroupModel(
        id: 'legion2',
        name: 'Legion 2',
        description:
            'Feste Teilnahme in Legion 2',
        maxPlayers: 30,
        allowsRegistration: true,
        sortOrder: 3,
        eventDateTime:
            groupsById['legion2']
                ?.eventDateTime,
      ),
      EventGroupModel(
        id: 'reserve_legion2',
        name: 'Ersatz Legion 2',
        description:
            'Als Ersatz für Legion 2 verfügbar',
        maxPlayers: 10,
        allowsRegistration: true,
        sortOrder: 4,
        inheritsTimeFrom: 'legion2',
      ),
      EventGroupModel(
        id: 'no',
        name: 'Kann nicht',
        description:
            'Keine Teilnahme möglich',
        maxPlayers: 0,
        allowsRegistration: true,
        sortOrder: 5,
      ),
    ];

    await groupRepository.saveGroups(
      eventId: eventId,
      groups: desiredGroups,
    );
  }

  Future<void> saveSelection({
    required EventGroupModel group,
    required List<EventRegistrationModel>
        registrations,
  }) async {
    if (userId == null ||
        currentUser == null) {
      throw Exception(
        'Bitte zuerst dein Profil speichern.',
      );
    }

    final membersInGroup =
        registrations.where(
      (registration) =>
          registration.selection == group.id,
    );

    final alreadyInGroup =
        mySelection == group.id;

    if (!alreadyInGroup &&
        group.maxPlayers > 0 &&
        membersInGroup.length >=
            group.maxPlayers) {
      throw Exception(
        '${group.name} ist bereits voll.',
      );
    }

    isSavingSelection = true;
    notifyListeners();

    try {
      final registration =
          EventRegistrationModel(
        id: userId!,
        eventId: eventId,
        userId: userId!,
        playerName:
            currentUser!.playerName,
        alliance:
            currentUser!.alliance,
        role: currentUser!.role,
        selection: group.id,
        updatedAt: DateTime.now(),
      );

      await registrationRepository
          .saveRegistration(
        registration,
      );

      mySelection = group.id;
    } finally {
      isSavingSelection = false;
      notifyListeners();
    }
  }

  Future<void> saveGroupDateTime({
    required EventGroupModel group,
    required DateTime utcDateTime,
  }) async {
    if (!canEditEvent) {
      throw Exception(
        'Nur R4 und R5 dürfen Termine ändern.',
      );
    }

    if (group.inheritsTimeFrom != null &&
        group.inheritsTimeFrom!.isNotEmpty) {
      throw Exception(
        '${group.name} übernimmt den Termin automatisch.',
      );
    }

    isSavingDateTime = true;
    notifyListeners();

    try {
      await groupRepository.setGroupDateTime(
        eventId: eventId,
        groupId: group.id,
        dateTime: utcDateTime,
      );
    } finally {
      isSavingDateTime = false;
      notifyListeners();
    }
  }

  DateTime? resolvedDateTime({
    required EventGroupModel group,
    required List<EventGroupModel> groups,
  }) {
    if (group.eventDateTime != null) {
      return group.eventDateTime;
    }

    final sourceId =
        group.inheritsTimeFrom;

    if (sourceId == null ||
        sourceId.isEmpty) {
      return null;
    }

    for (final item in groups) {
      if (item.id == sourceId) {
        return item.eventDateTime;
      }
    }

    return null;
  }

  int playerCount({
    required EventGroupModel group,
    required List<EventRegistrationModel>
        registrations,
  }) {
    return registrations
        .where(
          (registration) =>
              registration.selection ==
              group.id,
        )
        .length;
  }

  bool isGroupFull({
    required EventGroupModel group,
    required List<EventRegistrationModel>
        registrations,
  }) {
    if (group.maxPlayers <= 0) {
      return false;
    }

    return playerCount(
          group: group,
          registrations: registrations,
        ) >=
        group.maxPlayers;
  }

  String capacityText({
    required EventGroupModel group,
    required List<EventRegistrationModel>
        registrations,
  }) {
    final count = playerCount(
      group: group,
      registrations: registrations,
    );

    if (group.maxPlayers <= 0) {
      return '$count';
    }

    return '$count / ${group.maxPlayers}';
  }
}
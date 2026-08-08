import 'dart:async';

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
import '../widgets/swordland/swordland_member_card.dart';
import '../widgets/swordland/swordland_move_member_dialog.dart';
import '../widgets/swordland/swordland_registration_card.dart';

class SwordlandPage extends StatefulWidget {
  const SwordlandPage({super.key});

  @override
  State<SwordlandPage> createState() =>
      _SwordlandPageState();
}

class _SwordlandPageState extends State<SwordlandPage> {
  final EventRepository _eventRepository =
      EventRepository();

  final EventGroupRepository _groupRepository =
      EventGroupRepository();

  final RegistrationRepository _registrationRepository =
      RegistrationRepository();

  final DeviceService _deviceService =
      DeviceService();

  final ProfileService _profileService =
      ProfileService();

  final String eventId = 'swordland';

  Timer? _timer;

  String? userId;
  UserModel? currentUser;
  String? mySelection;

  bool isLoading = true;
  bool isSavingSelection = false;
  bool isSavingDateTime = false;
  bool isMovingMember = false;

  bool get canEditEvent {
    return currentUser?.role == 'R4' ||
        currentUser?.role == 'R5';
  }

  @override
  void initState() {
    super.initState();

    initializePage();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> initializePage() async {
    try {
      await ensureSwordlandExists();
      await ensureSwordlandGroupsExist();

      final id =
          await _deviceService.getOrCreateUserId();

      final profile =
          await _profileService.loadProfile(id);

      final registration =
          await _registrationRepository.getRegistration(
        eventId: eventId,
        userId: id,
      );

      if (!mounted) return;

      setState(() {
        userId = id;
        currentUser = profile;
        mySelection = registration?.selection;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Swordland konnte nicht initialisiert werden: $e',
          ),
        ),
      );
    }
  }

  Future<void> ensureSwordlandExists() async {
    final existing =
        await _eventRepository.getEvent(
      eventId,
    );

    if (existing != null) {
      return;
    }

    final event = EventModel(
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

    await _eventRepository.saveEvent(
      event,
    );
  }

  Future<void> ensureSwordlandGroupsExist() async {
    final existingGroups =
        await _groupRepository
            .watchGroups(eventId)
            .first;

    EventGroupModel? findOldGroup(
      String id,
    ) {
      for (final group in existingGroups) {
        if (group.id == id) {
          return group;
        }
      }

      return null;
    }

    final groups = <EventGroupModel>[
      EventGroupModel(
        id: 'legion1',
        name: 'Legion 1',
        description:
            'Feste Teilnahme in Legion 1',
        maxPlayers: 30,
        allowsRegistration: true,
        sortOrder: 1,
        eventDateTime:
            findOldGroup('legion1')
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
            findOldGroup('legion2')
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

    await _groupRepository.saveGroups(
      eventId: eventId,
      groups: groups,
    );
  }

  Future<void> saveSelection(
    String selection,
  ) async {
    if (userId == null ||
        currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte zuerst dein Profil speichern.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSavingSelection = true;
    });

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
      selection: selection,
      updatedAt: DateTime.now(),
    );

    try {
      await _registrationRepository
          .saveRegistration(
        registration,
      );

      if (!mounted) return;

      setState(() {
        mySelection = selection;
        isSavingSelection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Swordland-Auswahl gespeichert ✅',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSavingSelection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Auswahl konnte nicht gespeichert werden: $e',
          ),
        ),
      );
    }
  }

  Future<void> moveMember({
    required EventRegistrationModel member,
    required List<EventGroupModel> groups,
    required List<EventRegistrationModel>
        registrations,
  }) async {
    if (!canEditEvent ||
        isMovingMember) {
      return;
    }

    final newGroupId =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return SwordlandMoveMemberDialog(
          member: member,
          groups: groups,
          registrations: registrations,
        );
      },
    );

    if (newGroupId == null ||
        newGroupId == member.selection) {
      return;
    }

    setState(() {
      isMovingMember = true;
    });

    try {
      await _registrationRepository
          .changeSelection(
        eventId: eventId,
        userId: member.userId,
        selection: newGroupId,
      );

      if (!mounted) return;

      if (member.userId == userId) {
        setState(() {
          mySelection = newGroupId;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.playerName} wurde verschoben ✅',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Spieler konnte nicht verschoben werden: $e',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isMovingMember = false;
    });
  }

  Future<void> chooseGroupDateTime(
    EventGroupModel group,
  ) async {
    if (!canEditEvent) {
      return;
    }

    final now =
        DateTime.now().toUtc();

    final current =
        group.eventDateTime ??
            DateTime.utc(
              now.year,
              now.month,
              now.day,
              group.id == 'legion2'
                  ? 14
                  : 19,
              group.id == 'legion2'
                  ? 0
                  : 30,
            );

    final selectedDate =
        await showDatePicker(
      context: context,
      initialDate: DateTime(
        current.year,
        current.month,
        current.day,
      ),
      firstDate:
          DateTime.now().subtract(
        const Duration(days: 1),
      ),
      lastDate:
          DateTime.now().add(
        const Duration(days: 730),
      ),
      helpText:
          '${group.name} - Datum',
      cancelText: 'Abbrechen',
      confirmText: 'Weiter',
    );

    if (selectedDate == null ||
        !mounted) {
      return;
    }

    final selectedTime =
        await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current.hour,
        minute: current.minute,
      ),
      helpText:
          '${group.name} - UTC Uhrzeit',
      cancelText: 'Abbrechen',
      confirmText: 'Speichern',
    );

    if (selectedTime == null) {
      return;
    }

    final selectedUtc =
        DateTime.utc(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    setState(() {
      isSavingDateTime = true;
    });

    try {
      await _groupRepository.setGroupDateTime(
        eventId: eventId,
        groupId: group.id,
        dateTime: selectedUtc,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${group.name} Termin gespeichert ✅',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Termin konnte nicht gespeichert werden: $e',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isSavingDateTime = false;
    });
  }

  DateTime? resolvedDateTime(
    EventGroupModel group,
    List<EventGroupModel> groups,
  ) {
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

  String formatDate(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return 'Kein Datum';
    }

    final utc =
        dateTime.toUtc();

    return '${utc.day.toString().padLeft(2, '0')}.'
        '${utc.month.toString().padLeft(2, '0')}.'
        '${utc.year}';
  }

  String formatTime(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return '--:-- UTC';
    }

    final utc =
        dateTime.toUtc();

    return '${utc.hour.toString().padLeft(2, '0')}:'
        '${utc.minute.toString().padLeft(2, '0')} UTC';
  }

  String countdownText(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return 'Noch kein Termin';
    }

    final difference =
        dateTime
            .toUtc()
            .difference(
              DateTime.now().toUtc(),
            );

    if (difference.isNegative) {
      return 'Event beendet';
    }

    final days =
        difference.inDays;

    final hours =
        difference.inHours
            .remainder(24);

    final minutes =
        difference.inMinutes
            .remainder(60);

    final seconds =
        difference.inSeconds
            .remainder(60);

    if (days > 0) {
      return '$days T • '
          '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${difference.inHours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  IconData getGroupIcon(
    String groupId,
  ) {
    switch (groupId) {
      case 'legion1':
        return Icons.looks_one;

      case 'reserve_legion1':
        return Icons.person_add_alt_1;

      case 'legion2':
        return Icons.looks_two;

      case 'reserve_legion2':
        return Icons.person_add_alt_1;

      case 'no':
        return Icons.cancel_outlined;

      default:
        return Icons.groups;
    }
  }

  Widget scheduleCard({
    required EventGroupModel group,
    required List<EventGroupModel> groups,
  }) {
    final dateTime =
        resolvedDateTime(
      group,
      groups,
    );

    final inherits =
        group.inheritsTimeFrom != null &&
            group.inheritsTimeFrom!.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFF1C1921),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              Colors.amber.withOpacity(0.22),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                getGroupIcon(
                  group.id,
                ),
                color: Colors.amber,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  group.name,
                  style:
                      const TextStyle(
                    color: Colors.amber,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            formatDate(
              dateTime,
            ),
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            formatTime(
              dateTime,
            ),
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            countdownText(
              dateTime,
            ),
            style:
                const TextStyle(
              color: Colors.amber,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          if (inherits)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 8,
              ),
              child: Text(
                'Termin wird automatisch übernommen.',
                style: TextStyle(
                  color:
                      Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),

          if (canEditEvent &&
              !inherits &&
              group.id != 'no') ...[
            const SizedBox(
              height: 14,
            ),

            SizedBox(
              width:
                  double.infinity,
              child:
                  OutlinedButton.icon(
                onPressed:
                    isSavingDateTime
                        ? null
                        : () {
                            chooseGroupDateTime(
                              group,
                            );
                          },
                icon:
                    const Icon(
                  Icons.edit_calendar,
                ),
                label: Text(
                  '${group.name} Termin ändern',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget registrationCard({
    required EventGroupModel group,
    required List<EventRegistrationModel>
        registrations,
  }) {
    final currentPlayers =
        registrations
            .where(
              (registration) =>
                  registration.selection ==
                  group.id,
            )
            .length;

    final selected =
        mySelection == group.id;

    final isFull =
        group.maxPlayers > 0 &&
            currentPlayers >=
                group.maxPlayers;

    return SwordlandRegistrationCard(
      group: group,
      selected: selected,
      isFull: isFull,
      isSaving:
          isSavingSelection,
      currentPlayers:
          currentPlayers,
      onTap: () async {
        if (isFull && !selected) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                '${group.name} ist bereits voll.',
              ),
            ),
          );

          return;
        }

        await saveSelection(
          group.id,
        );
      },
    );
  }

  Widget liveGroupList({
    required EventGroupModel group,
    required List<EventGroupModel> groups,
    required List<EventRegistrationModel>
        registrations,
  }) {
    final members =
        registrations
            .where(
              (registration) =>
                  registration.selection ==
                  group.id,
            )
            .toList();

    final capacityText =
        group.maxPlayers > 0
            ? '${members.length} / ${group.maxPlayers}'
            : '${members.length}';

    final full =
        group.maxPlayers > 0 &&
            members.length >=
                group.maxPlayers;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF1C1921),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                getGroupIcon(
                  group.id,
                ),
                color:
                    Colors.amber,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  group.name,
                  style:
                      const TextStyle(
                    color:
                        Colors.amber,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              if (full)
                Container(
                  margin:
                      const EdgeInsets.only(
                    right: 10,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.redAccent
                        .withOpacity(
                          0.15,
                        ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child:
                      const Text(
                    'VOLL',
                    style:
                        TextStyle(
                      color:
                          Colors.redAccent,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

              Text(
                capacityText,
                style:
                    TextStyle(
                  color: full
                      ? Colors.redAccent
                      : Colors.amber,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          if (members.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 10,
              ),
              child: Text(
                'Noch niemand eingetragen.',
                style: TextStyle(
                  color:
                      Colors.white54,
                ),
              ),
            ),

          ...members.map(
            (member) =>
                SwordlandMemberCard(
              member: member,
              canManage: canEditEvent,
              onTap: () {
                moveMember(
                  member: member,
                  groups: groups,
                  registrations:
                      registrations,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F0D13),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F0D13),
        centerTitle: true,
        title: const Text(
          '⚔️ Swordland',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : StreamBuilder<EventModel?>(
              stream:
                  _eventRepository.watchEvent(
                eventId,
              ),
              builder: (
                context,
                eventSnapshot,
              ) {
                if (eventSnapshot.hasError) {
                  return Center(
                    child: Text(
                      '${eventSnapshot.error}',
                      style:
                          const TextStyle(
                        color:
                            Colors.redAccent,
                      ),
                    ),
                  );
                }

                if (!eventSnapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final event =
                    eventSnapshot.data;

                if (event == null) {
                  return const Center(
                    child: Text(
                      'Swordland nicht gefunden.',
                    ),
                  );
                }

                return StreamBuilder<
                    List<EventGroupModel>>(
                  stream:
                      _groupRepository
                          .watchGroups(
                    eventId,
                  ),
                  builder: (
                    context,
                    groupSnapshot,
                  ) {
                    final groups =
                        groupSnapshot.data ??
                            [];

                    if (groups.isEmpty) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    return StreamBuilder<
                        List<EventRegistrationModel>>(
                      stream:
                          _registrationRepository
                              .watchRegistrations(
                        eventId,
                      ),
                      builder: (
                        context,
                        registrationSnapshot,
                      ) {
                        final registrations =
                            registrationSnapshot
                                    .data ??
                                [];

                        return ListView(
                          padding:
                              const EdgeInsets.all(
                            20,
                          ),
                          children: [
                            const Center(
                              child: Icon(
                                Icons.gavel,
                                size: 70,
                                color:
                                    Colors.amber,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            const Center(
                              child: Text(
                                'SWORDLAND',
                                style:
                                    TextStyle(
                                  color:
                                      Colors.amber,
                                  fontSize:
                                      30,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 25,
                            ),

                            const Text(
                              '📅 Termine',
                              style:
                                  TextStyle(
                                fontSize:
                                    22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            ...groups
                                .where(
                                  (group) =>
                                      group.id ==
                                          'legion1' ||
                                      group.id ==
                                          'legion2',
                                )
                                .map(
                                  (group) =>
                                      scheduleCard(
                                    group:
                                        group,
                                    groups:
                                        groups,
                                  ),
                                ),

                            const SizedBox(
                              height: 18,
                            ),

                            Text(
                              currentUser == null
                                  ? 'Teilnahme'
                                  : 'Teilnahme für ${currentUser!.playerName}',
                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            if (event
                                .registrationOpen)
                              ...groups.map(
                                (group) =>
                                    registrationCard(
                                  group:
                                      group,
                                  registrations:
                                      registrations,
                                ),
                              ),

                            const SizedBox(
                              height: 25,
                            ),

                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '👥 Live-Einteilung',
                                    style:
                                        TextStyle(
                                      fontSize: 22,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                                if (canEditEvent)
                                  const Text(
                                    'Tippen zum Verschieben',
                                    style: TextStyle(
                                      color:
                                          Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            ...groups.map(
                              (group) =>
                                  liveGroupList(
                                group:
                                    group,
                                groups:
                                    groups,
                                registrations:
                                    registrations,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
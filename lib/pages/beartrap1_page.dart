import 'package:flutter/material.dart';

import '../models/event_registration_model.dart';
import '../models/user_model.dart';
import '../services/device_service.dart';
import '../services/event_registration_service.dart';
import '../services/firestore_service.dart';
import '../services/profile_service.dart';

class BearTrap1Page extends StatefulWidget {
  const BearTrap1Page({super.key});

  @override
  State<BearTrap1Page> createState() => _BearTrap1PageState();
}

class _BearTrap1PageState extends State<BearTrap1Page> {
  final FirestoreService _firestoreService = FirestoreService();
  final ProfileService _profileService = ProfileService();
  final DeviceService _deviceService = DeviceService();
  final EventRegistrationService _registrationService =
      EventRegistrationService();

  final String eventId = 'beartrap1';

  String? userId;
  String startTime = '19:30';
  String? mySelection;

  UserModel? currentUser;

  bool isLoading = true;
  bool isSavingRegistration = false;

  bool get canEditEventTime {
    return currentUser?.role == 'R4' || currentUser?.role == 'R5';
  }

  @override
  void initState() {
    super.initState();
    loadPageData();
  }

  Future<void> loadPageData() async {
    try {
      final id = await _deviceService.getOrCreateUserId();

      final time =
          await _firestoreService.loadBearTrap1Time();

      final profile =
          await _profileService.loadProfile(id);

      final registration =
          await _registrationService.getRegistration(
        eventId: eventId,
        userId: id,
      );

      if (!mounted) return;

      setState(() {
        userId = id;
        startTime = time.replaceAll(' UTC', '');
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
            'Fehler beim Laden: $e',
          ),
        ),
      );
    }
  }

  Future<void> changeStartTime() async {
    if (!canEditEventTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nur R4 und R5 dürfen die Startzeit ändern.',
          ),
        ),
      );
      return;
    }

    final parts = startTime.split(':');

    final currentTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      helpText: 'Startzeit für Bärenfalle 1',
      cancelText: 'Abbrechen',
      confirmText: 'Speichern',
    );

    if (selectedTime == null) return;

    final formattedTime =
        '${selectedTime.hour.toString().padLeft(2, '0')}:'
        '${selectedTime.minute.toString().padLeft(2, '0')}';

    try {
      await _firestoreService.saveBearTrap1Time(
        '$formattedTime UTC',
      );

      if (!mounted) return;

      setState(() {
        startTime = formattedTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Startzeit wurde in der Cloud gespeichert.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Speichern fehlgeschlagen: $e',
          ),
        ),
      );
    }
  }

  Future<void> saveParticipation(
    String selection,
  ) async {
    if (userId == null || currentUser == null) {
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
      isSavingRegistration = true;
    });

    final registration = EventRegistrationModel(
      id: userId!,
      eventId: eventId,
      userId: userId!,
      playerName: currentUser!.playerName,
      alliance: currentUser!.alliance,
      selection: selection,
      updatedAt: DateTime.now(),
    );

    try {
      await _registrationService.saveRegistration(
        registration,
      );

      if (!mounted) return;

      setState(() {
        mySelection = selection;
        isSavingRegistration = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selection == 'yes'
                ? 'Teilnahme gespeichert ✅'
                : 'Absage gespeichert ❌',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSavingRegistration = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anmeldung konnte nicht gespeichert werden: $e',
          ),
        ),
      );
    }
  }

  Widget participationButton({
    required String title,
    required IconData icon,
    required String selection,
  }) {
    final selected = mySelection == selection;

    return Expanded(
      child: ElevatedButton.icon(
        onPressed: isSavingRegistration
            ? null
            : () {
                saveParticipation(selection);
              },
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? Colors.amber : const Color(0xFF1C1921),
          foregroundColor:
              selected ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
        ),
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1921),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.amber,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget participantList() {
    return StreamBuilder<List<EventRegistrationModel>>(
      stream: _registrationService.watchRegistrations(
        eventId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Teilnehmer konnten nicht geladen werden.',
            style: TextStyle(
              color: Colors.redAccent,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final registrations = snapshot.data!;

        final participants = registrations
            .where(
              (registration) =>
                  registration.selection == 'yes',
            )
            .toList();

        final declined = registrations
            .where(
              (registration) =>
                  registration.selection == 'no',
            )
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teilnehmer (${participants.length})',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),

            const SizedBox(height: 12),

            if (participants.isEmpty)
              const Text(
                'Noch keine Teilnehmer.',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

            ...participants.map(
              (registration) => Card(
                color: const Color(0xFF1C1921),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                  ),
                  title: Text(
                    registration.playerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    registration.alliance,
                  ),
                  trailing: const Text(
                    '✅',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Absagen (${declined.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 8),

            if (declined.isEmpty)
              const Text(
                'Keine Absagen.',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),

            ...declined.map(
              (registration) => ListTile(
                dense: true,
                leading: const Icon(
                  Icons.cancel,
                  color: Colors.white54,
                ),
                title: Text(
                  registration.playerName,
                ),
                subtitle: Text(
                  registration.alliance,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0D13),
        title: const Text(
          '🐻 Bärenfalle 1',
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Center(
                  child: Icon(
                    Icons.pets,
                    size: 72,
                    color: Colors.amber,
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    'BÄRENFALLE 1',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    '$startTime UTC',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (canEditEventTime)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: changeStartTime,
                      icon: const Icon(
                        Icons.schedule,
                      ),
                      label: const Text(
                        'Startzeit ändern',
                      ),
                    ),
                  ),

                if (!canEditEventTime)
                  const Center(
                    child: Text(
                      'Startzeit wird vom Leadership verwaltet.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                Text(
                  currentUser == null
                      ? 'Teilnahme'
                      : 'Teilnahme für ${currentUser!.playerName}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    participationButton(
                      title: 'Teilnehmen',
                      icon: Icons.check_circle,
                      selection: 'yes',
                    ),
                    const SizedBox(width: 10),
                    participationButton(
                      title: 'Absagen',
                      icon: Icons.cancel,
                      selection: 'no',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                participantList(),

                const SizedBox(height: 30),

                infoCard(
                  icon: Icons.campaign,
                  title: 'Rally Leader',
                  text:
                      'Hier tragen wir später die Rally Leader ein.',
                ),

                infoCard(
                  icon: Icons.groups,
                  title: 'Joiner',
                  text:
                      'Hier kommen später die empfohlenen Joiner-Helden hinein.',
                ),

                infoCard(
                  icon: Icons.rule,
                  title: 'Regeln',
                  text:
                      'Hier kommen später die Regeln für Bärenfalle 1 hinein.',
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
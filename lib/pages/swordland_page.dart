import 'package:flutter/material.dart';

import '../models/event_group_model.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class SwordlandPage extends StatefulWidget {
  const SwordlandPage({super.key});

  @override
  State<SwordlandPage> createState() => _SwordlandPageState();
}

class _SwordlandPageState extends State<SwordlandPage> {
  final EventService _eventService = EventService();

  final String eventId = 'swordland';

  bool isCreating = false;

  Future<void> createOrUpdateSwordland() async {
    final swordland = EventModel(
      id: eventId,
      title: 'Swordland',
      description:
          'Legionen, Ersatzspieler, Teams, Gebäude und Strategie.',
      startTime: '19:30 UTC',
      eventType: 'swordland',
      isActive: true,
      registrationOpen: true,
      hasGroups: true,
      hasTeams: true,
      hasGuide: true,
      hasCountdown: true,
      groups: const [
        EventGroupModel(
          id: 'legion1',
          name: 'Legion 1',
          description: 'Feste Teilnahme in Legion 1',
          maxPlayers: 0,
          allowsRegistration: true,
          sortOrder: 1,
        ),
        EventGroupModel(
          id: 'reserve_legion1',
          name: 'Ersatz Legion 1',
          description: 'Als Ersatz für Legion 1 verfügbar',
          maxPlayers: 0,
          allowsRegistration: true,
          sortOrder: 2,
        ),
        EventGroupModel(
          id: 'legion2',
          name: 'Legion 2',
          description: 'Feste Teilnahme in Legion 2',
          maxPlayers: 0,
          allowsRegistration: true,
          sortOrder: 3,
        ),
        EventGroupModel(
          id: 'reserve_legion2',
          name: 'Ersatz Legion 2',
          description: 'Als Ersatz für Legion 2 verfügbar',
          maxPlayers: 0,
          allowsRegistration: true,
          sortOrder: 4,
        ),
        EventGroupModel(
          id: 'no',
          name: 'Kann nicht',
          description: 'Keine Teilnahme möglich',
          maxPlayers: 0,
          allowsRegistration: true,
          sortOrder: 5,
        ),
      ],
    );

    await _eventService.saveEvent(swordland);
  }

  @override
  void initState() {
    super.initState();
    initializeSwordland();
  }

  Future<void> initializeSwordland() async {
    setState(() {
      isCreating = true;
    });

    try {
      await createOrUpdateSwordland();
    } finally {
      if (!mounted) return;

      setState(() {
        isCreating = false;
      });
    }
  }

  IconData getGroupIcon(String groupId) {
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

  String getGroupBadge(String groupId) {
    switch (groupId) {
      case 'legion1':
        return 'L1';
      case 'reserve_legion1':
        return 'E1';
      case 'legion2':
        return 'L2';
      case 'reserve_legion2':
        return 'E2';
      case 'no':
        return '✕';
      default:
        return '';
    }
  }

  Widget groupCard(EventGroupModel group) {
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
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.amber.withOpacity(0.15),
            child: Icon(
              getGroupIcon(group.id),
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  group.description,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              getGroupBadge(group.id),
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.amber,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0D13),
        centerTitle: true,
        title: const Text(
          '⚔️ Swordland',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isCreating
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<EventModel?>(
              stream: _eventService.watchEvent(eventId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Swordland konnte nicht geladen werden.\n\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final event = snapshot.data;

                if (event == null) {
                  return const Center(
                    child: Text(
                      'Swordland ist noch nicht eingerichtet.',
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Center(
                      child: Icon(
                        Icons.gavel,
                        color: Colors.amber,
                        size: 72,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        event.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        event.startTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        event.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Teilnahme',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.registrationOpen
                          ? 'Wähle deine Legion oder den passenden Ersatzbereich.'
                          : 'Die Anmeldung ist momentan geschlossen.',
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (event.hasGroups)
                      ...event.groups.map(groupCard),
                    const SizedBox(height: 20),
                    if (event.hasTeams)
                      infoCard(
                        icon: Icons.grid_view,
                        title: 'Teamaufteilung',
                        text:
                            'Als Nächstes bauen wir Team 1–4 und die Verteilung innerhalb der beiden Legionen.',
                      ),
                    if (event.hasGuide)
                      infoCard(
                        icon: Icons.menu_book,
                        title: 'Strategie',
                        text:
                            'Hier kommen später Gebäude, Startaufstellung und die Swordland-Strategie hinein.',
                      ),
                    infoCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Leadership',
                      text:
                          'R4/R5 können später Spieler zwischen Legion und Ersatz verschieben und Teams zusammenstellen.',
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'beartrap1_page.dart';
import 'beartrap2_page.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  void openPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  Widget eventCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget page,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFF1C1921),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.amber.withOpacity(0.15),
          child: Icon(
            icon,
            color: Colors.amber,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 17,
          color: Colors.amber,
        ),
        onTap: () {
          openPage(context, page);
        },
      ),
    );
  }

  Widget comingSoonCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFF1C1921),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.amber.withOpacity(0.15),
          child: Icon(
            icon,
            color: Colors.amber,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(
          Icons.lock_outline,
          size: 20,
          color: Colors.white54,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title kommt als Nächstes.'),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsStream = FirebaseFirestore.instance
        .collection('settings')
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0D13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0D13),
        title: const Text('📅 Events'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: settingsStream,
        builder: (context, snapshot) {
          String bearTrap1Time = '19:30 UTC';
          String bearTrap2Time = '14:00 UTC';

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data();

              if (doc.id == 'beartrap1') {
                bearTrap1Time =
                    data['time']?.toString() ?? bearTrap1Time;
              }

              if (doc.id == 'beartrap2') {
                bearTrap2Time =
                    data['time']?.toString() ?? bearTrap2Time;
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Kingshot Events',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Wähle ein Event aus.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 25),

              eventCard(
                context: context,
                title: 'Bärenfalle 1',
                subtitle: '$bearTrap1Time • Anmeldung & Guide',
                icon: Icons.pets,
                page: const BearTrap1Page(),
              ),

              eventCard(
                context: context,
                title: 'Bärenfalle 2',
                subtitle: '$bearTrap2Time • Anmeldung & Guide',
                icon: Icons.pets,
                page: const BearTrap2Page(),
              ),

              comingSoonCard(
                context: context,
                title: 'Vikings',
                subtitle: 'Wellen, Verstärkung und Regeln',
                icon: Icons.local_fire_department,
              ),

              comingSoonCard(
                context: context,
                title: 'Swordland',
                subtitle: 'Legionen, Teams und Gebäude',
                icon: Icons.gavel,
              ),

              comingSoonCard(
                context: context,
                title: 'Tri Alliance',
                subtitle: 'Teilnahme und Einsatzplanung',
                icon: Icons.groups,
              ),

              comingSoonCard(
                context: context,
                title: 'Alliance Championship',
                subtitle: 'Planung und Teilnehmer',
                icon: Icons.emoji_events,
              ),

              comingSoonCard(
                context: context,
                title: 'Alliance Mobilization',
                subtitle: 'Aufgaben und Fortschritt',
                icon: Icons.checklist,
              ),
            ],
          );
        },
      ),
    );
  }
}
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'beartrap1_page.dart';
import 'beartrap2_page.dart';
import 'swordland_page.dart';

class EventCalendarPage extends StatefulWidget {
  const EventCalendarPage({super.key});

  @override
  State<EventCalendarPage> createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Duration calculateCountdown(String time) {
    final cleanTime = time.replaceAll(' UTC', '');
    final parts = cleanTime.split(':');

    if (parts.length != 2) {
      return Duration.zero;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return Duration.zero;
    }

    final now = DateTime.now().toUtc();

    var eventTime = DateTime.utc(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!eventTime.isAfter(now)) {
      eventTime = eventTime.add(
        const Duration(days: 1),
      );
    }

    return eventTime.difference(now);
  }

  String formatCountdown(Duration duration) {
    final hours =
        duration.inHours.toString().padLeft(2, '0');

    final minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  Widget eventCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    Widget? page,
  }) {
    final countdown = calculateCountdown(time);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1921),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.18),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor:
              Colors.amber.withOpacity(0.14),
          child: Icon(
            icon,
            color: Colors.amber,
            size: 29,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '$time • ${formatCountdown(countdown)}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: page == null
            ? const Icon(
                Icons.lock_outline,
                color: Colors.white38,
              )
            : const Icon(
                Icons.arrow_forward_ios,
                size: 17,
                color: Colors.amber,
              ),
        onTap: page == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => page,
                  ),
                );
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F0D13),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F0D13),
        centerTitle: true,
        title: const Text(
          'Events',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('settings')
            .snapshots(),
        builder: (context, snapshot) {
          String bearTrap1Time = '19:30 UTC';
          String bearTrap2Time = '14:00 UTC';

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final data = doc.data();

              if (doc.id == 'beartrap1') {
                bearTrap1Time =
                    data['time']?.toString() ??
                        bearTrap1Time;
              }

              if (doc.id == 'beartrap2') {
                bearTrap2Time =
                    data['time']?.toString() ??
                        bearTrap2Time;
              }
            }
          }

          return StreamBuilder<
              DocumentSnapshot<
                  Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .doc('swordland')
                .snapshots(),
            builder: (
              context,
              swordlandSnapshot,
            ) {
              String swordlandTime = '19:30 UTC';

              if (swordlandSnapshot.hasData &&
                  swordlandSnapshot.data!.exists) {
                final data =
                    swordlandSnapshot.data!.data();

                swordlandTime =
                    data?['startTime']?.toString() ??
                        swordlandTime;
              }

              return ListView(
                padding:
                    const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Nächste Events',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 27,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Alle wichtigen SKS-Events auf einen Blick.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  eventCard(
                    context: context,
                    title: 'Bärenfalle 1',
                    subtitle:
                        'Teilnahme, Rally Leader und Regeln',
                    time: bearTrap1Time,
                    icon: Icons.pets,
                    page:
                        const BearTrap1Page(),
                  ),

                  eventCard(
                    context: context,
                    title: 'Bärenfalle 2',
                    subtitle:
                        'Teilnahme, Rally Leader und Regeln',
                    time: bearTrap2Time,
                    icon: Icons.pets,
                    page:
                        const BearTrap2Page(),
                  ),

                  eventCard(
                    context: context,
                    title: 'Swordland',
                    subtitle:
                        'Legion 1, Legion 2 und Strategie',
                    time: swordlandTime,
                    icon: Icons.gavel,
                    page:
                        const SwordlandPage(),
                  ),

                  eventCard(
                    context: context,
                    title: 'Tri Alliance',
                    subtitle:
                        'Legion 1, Legion 2 und Planung',
                    time: '19:30 UTC',
                    icon: Icons.groups,
                  ),

                  eventCard(
                    context: context,
                    title: 'Vikings',
                    subtitle:
                        'Wellen, Verstärkung und Regeln',
                    time: '19:30 UTC',
                    icon:
                        Icons.local_fire_department,
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF1C1921),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Swordland läuft jetzt bereits über die neue Event-Engine. Tri Alliance und Vikings folgen danach.',
                            style: TextStyle(
                              color:
                                  Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
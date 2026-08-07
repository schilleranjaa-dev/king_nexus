import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/event_registration_model.dart';
import '../models/user_model.dart';
import '../services/device_service.dart';
import '../services/event_registration_service.dart';
import '../services/profile_service.dart';
import 'beartrap1_page.dart';
import 'beartrap2_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DeviceService _deviceService = DeviceService();
  final ProfileService _profileService = ProfileService();
  final EventRegistrationService _registrationService =
      EventRegistrationService();

  Timer? _timer;

  UserModel? currentUser;

  String bearTrap1Time = '19:30 UTC';
  String bearTrap2Time = '14:00 UTC';

  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();

    _loadUser();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Future<void> _loadUser() async {
    try {
      final userId =
          await _deviceService.getOrCreateUserId();

      final profile =
          await _profileService.loadProfile(userId);

      if (!mounted) return;

      setState(() {
        currentUser = profile;
        isLoadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingUser = false;
      });
    }
  }

  Duration _countdownTo(String time) {
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

    var target = DateTime.utc(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!target.isAfter(now)) {
      target = target.add(
        const Duration(days: 1),
      );
    }

    return target.difference(now);
  }

  String _formatCountdown(Duration duration) {
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

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 95,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1921),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.amber.withOpacity(0.18),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.amber,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newsCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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

  Widget _registrationCount({
    required String eventId,
    required String title,
    required IconData icon,
  }) {
    return StreamBuilder<List<EventRegistrationModel>>(
      stream:
          _registrationService.watchRegistrations(
        eventId,
      ),
      builder: (context, snapshot) {
        final registrations =
            snapshot.data ?? [];

        final participants =
            registrations.where(
          (registration) =>
              registration.selection == 'yes',
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1921),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${participants.length}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('settings')
          .snapshots(),
      builder: (context, snapshot) {
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

        final countdown =
            _countdownTo(bearTrap1Time);

        final playerName =
            currentUser?.playerName.trim();

        return Scaffold(
          backgroundColor:
              const Color(0xFF0F0D13),
          body: SafeArea(
            child: ListView(
              padding:
                  const EdgeInsets.all(20),
              children: [
                const Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 66,
                    color: Colors.amber,
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'KING NEXUS',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 29,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Center(
                  child: Text(
                    isLoadingUser
                        ? 'Alliance Companion'
                        : playerName == null ||
                                playerName.isEmpty
                            ? 'Alliance Companion'
                            : 'Willkommen zurück, $playerName',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF1C1921),
                    borderRadius:
                        BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.amber
                          .withOpacity(0.45),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🔥 NÄCHSTES EVENT',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        '🐻 Bärenfalle 1',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        bearTrap1Time,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 17),

                      Text(
                        _formatCountdown(
                          countdown,
                        ),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 38,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'bis zum Start',
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            _openPage(
                              const BearTrap1Page(),
                            );
                          },
                          icon: const Icon(
                            Icons.pets,
                          ),
                          label: const Text(
                            'Bärenfalle 1 öffnen',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  '⚡ Schnellaktionen',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 13),

                Row(
                  children: [
                    _quickAction(
                      icon: Icons.pets,
                      title: 'Falle 1',
                      onTap: () {
                        _openPage(
                          const BearTrap1Page(),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _quickAction(
                      icon: Icons.pets,
                      title: 'Falle 2',
                      onTap: () {
                        _openPage(
                          const BearTrap2Page(),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  '👥 Live-Teilnahmen',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 13),

                _registrationCount(
                  eventId: 'beartrap1',
                  title: 'Bärenfalle 1',
                  icon: Icons.pets,
                ),

                _registrationCount(
                  eventId: 'beartrap2',
                  title: 'Bärenfalle 2',
                  icon: Icons.pets,
                ),

                const SizedBox(height: 28),

                const Text(
                  '📢 Aktuelles',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 13),

                _newsCard(
                  icon: Icons.campaign,
                  title: 'Allianz-News',
                  text:
                      'Hier erscheinen bald aktuelle Nachrichten von SKS.',
                ),

                _newsCard(
                  icon: Icons.savings,
                  title: 'KvK',
                  text:
                      'Für KvK Ressourcen und wichtige Items sparen.',
                ),

                _newsCard(
                  icon: Icons.card_giftcard,
                  title: 'Gift Codes',
                  text:
                      'Neue Gift Codes werden später direkt hier angezeigt.',
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/device_service.dart';
import '../services/profile_service.dart';
import 'admin_page.dart';

class AlliancePage extends StatefulWidget {
  const AlliancePage({super.key});

  @override
  State<AlliancePage> createState() => _AlliancePageState();
}

class _AlliancePageState extends State<AlliancePage> {
  final DeviceService _deviceService = DeviceService();
  final ProfileService _profileService = ProfileService();

  UserModel? currentUser;
  bool isLoading = true;

  bool get isLeadership {
    return currentUser?.role == 'R4' ||
        currentUser?.role == 'R5';
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final userId =
          await _deviceService.getOrCreateUserId();

      final profile =
          await _profileService.loadProfile(userId);

      print('==============================');
      print('KING NEXUS USER CHECK');
      print('UserID: $userId');
      print('Player: ${profile?.playerName}');
      print('Role: ${profile?.role}');
      print('isAdmin: ${profile?.isAdmin}');
      print('==============================');

      if (!mounted) return;

      setState(() {
        currentUser = profile;
        isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Laden des Benutzers: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Benutzer konnte nicht geladen werden: $e',
          ),
        ),
      );
    }
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
          CircleAvatar(
            radius: 24,
            backgroundColor:
                Colors.amber.withOpacity(0.15),
            child: Icon(
              icon,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget contactRow({
    required String event,
    required String contact,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chevron_right,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
                children: [
                  TextSpan(
                    text: '$event: ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: contact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openAdminPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AdminPage(),
      ),
    ).then((_) {
      loadUser();
    });
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
          '🛡️ Alliance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(20),
              children: [
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shield,
                        size: 76,
                        color: Colors.amber,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'SKS',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 34,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Silent Kings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Kingdom 1631',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                if (currentUser != null)
                  Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),
                    padding:
                        const EdgeInsets.all(
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
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor:
                              Colors.amber,
                          child: Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                currentUser!
                                        .playerName
                                        .isEmpty
                                    ? 'Unbekannter Spieler'
                                    : currentUser!
                                        .playerName,
                                style:
                                    const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                currentUser!.role ==
                                        'Member'
                                    ? 'Mitglied'
                                    : currentUser!
                                        .role,
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.amber,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isLeadership)
                  Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(
                      bottom: 18,
                    ),
                    child:
                        ElevatedButton.icon(
                      onPressed: openAdminPage,
                      icon: const Icon(
                        Icons
                            .admin_panel_settings,
                      ),
                      label: const Text(
                        '👑 Leadership Center',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.amber,
                        foregroundColor:
                            Colors.black,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 17,
                        ),
                        textStyle:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (!isLeadership &&
                    currentUser != null)
                  Container(
                    width: double.infinity,
                    margin:
                        const EdgeInsets.only(
                      bottom: 18,
                    ),
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF1C1921),
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.white54,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Leadership-Funktionen sind nur für R4 und R5 verfügbar.',
                            style: TextStyle(
                              color:
                                  Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                infoCard(
                  icon:
                      Icons.workspace_premium,
                  title: 'Leadership',
                  text:
                      'R5: Chico\n\nR4-Team und weitere Rollen werden später automatisch aus Firebase geladen.',
                ),

                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF1C1921),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                    border: Border.all(
                      color: Colors.amber
                          .withOpacity(0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Ansprechpartner',
                            style: TextStyle(
                              color:
                                  Colors.amber,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      contactRow(
                        event: 'Swordland',
                        contact:
                            'Legion 1: RPS • Legion 2: Anja',
                      ),

                      contactRow(
                        event: 'Tri Alliance',
                        contact:
                            'Legion 1: Chico • Legion 2: Tactical Rabbit',
                      ),

                      contactRow(
                        event: 'Vikings',
                        contact: 'Tarifa',
                      ),

                      contactRow(
                        event:
                            'Bärenfalle 1',
                        contact: 'RPS',
                      ),

                      contactRow(
                        event:
                            'Bärenfalle 2',
                        contact: 'Anjaa',
                      ),
                    ],
                  ),
                ),

                infoCard(
                  icon: Icons.rule,
                  title: 'Allianzregeln',
                  text:
                      '• Keine Arena-Angriffe gegen SKS.\n'
                      '• Eventregeln und aktuelle Hinweise beachten.\n'
                      '• Bei Fragen oder Problemen an das Leadership-Team wenden.',
                ),

                infoCard(
                  icon: Icons.forum,
                  title: 'Discord',
                  text:
                      'Hier bauen wir später einen direkten Discord-Button und die Discord-Anmeldung ein.',
                ),

                infoCard(
                  icon: Icons.groups,
                  title: 'Mitglieder',
                  text:
                      'Die Mitgliederliste wird direkt aus Firebase geladen.',
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/device_service.dart';
import '../services/profile_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceService _deviceService = DeviceService();
  final ProfileService _profileService = ProfileService();

  final TextEditingController searchController = TextEditingController();

  UserModel? currentUser;

  bool isLoading = true;
  String searchQuery = '';
  String sortMode = 'name';

  bool get isLeadership {
    return currentUser?.role == 'R4' ||
        currentUser?.role == 'R5';
  }

  bool get isR5 {
    return currentUser?.role == 'R5';
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    try {
      final userId =
          await _deviceService.getOrCreateUserId();

      final profile =
          await _profileService.loadProfile(userId);

      if (!mounted) return;

      setState(() {
        currentUser = profile;
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
            'Leadership Center konnte nicht geladen werden: $e',
          ),
        ),
      );
    }
  }

  Stream<List<UserModel>> watchUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(
            (doc) {
              return UserModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              });
            },
          ).toList(),
        );
  }

  List<UserModel> filterAndSortUsers(
    List<UserModel> users,
  ) {
    final query = searchQuery.trim().toLowerCase();

    var filtered = users.where((user) {
      if (query.isEmpty) {
        return true;
      }

      return user.playerName
              .toLowerCase()
              .contains(query) ||
          user.alliance
              .toLowerCase()
              .contains(query) ||
          user.discordName
              .toLowerCase()
              .contains(query) ||
          user.role
              .toLowerCase()
              .contains(query);
    }).toList();

    if (sortMode == 'name') {
      filtered.sort(
        (a, b) => a.playerName
            .toLowerCase()
            .compareTo(
              b.playerName.toLowerCase(),
            ),
      );
    }

    if (sortMode == 'furnace') {
      filtered.sort(
        (a, b) => b.furnaceLevel
            .compareTo(a.furnaceLevel),
      );
    }

    if (sortMode == 'role') {
      int roleValue(String role) {
        if (role == 'R5') return 3;
        if (role == 'R4') return 2;
        return 1;
      }

      filtered.sort(
        (a, b) => roleValue(b.role)
            .compareTo(roleValue(a.role)),
      );
    }

    return filtered;
  }

  Future<void> changeRole(
    UserModel user,
    String newRole,
  ) async {
    if (!isLeadership) {
      return;
    }

    if (currentUser == null) {
      return;
    }

    if (user.id == currentUser!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Du kannst deine eigene Rolle hier nicht ändern.',
          ),
        ),
      );
      return;
    }

    if (newRole == 'R5' && !isR5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nur R5 darf die Rolle R5 vergeben.',
          ),
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF1C1921),
          title: const Text(
            'Rolle ändern?',
          ),
          content: Text(
            '${user.playerName} wirklich zu $newRole ändern?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Bestätigen'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update({
        'role': newRole,
        'isAdmin':
            newRole == 'R4' ||
                newRole == 'R5',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user.playerName} ist jetzt ${newRole == 'Member' ? 'Mitglied' : newRole}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rolle konnte nicht geändert werden: $e',
          ),
        ),
      );
    }
  }

  Future<void> showRoleDialog(
    UserModel user,
  ) async {
    if (currentUser == null) {
      return;
    }

    if (user.id == currentUser!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Deine eigene Rolle kann hier nicht geändert werden.',
          ),
        ),
      );
      return;
    }

    String selectedRole = user.role;

    final result =
        await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  const Color(0xFF1C1921),
              title: Text(
                user.playerName.isEmpty
                    ? 'Mitglied'
                    : user.playerName,
              ),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'Member',
                    groupValue:
                        selectedRole,
                    activeColor:
                        Colors.amber,
                    title:
                        const Text('Mitglied'),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(() {
                        selectedRole = value;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    value: 'R4',
                    groupValue:
                        selectedRole,
                    activeColor:
                        Colors.amber,
                    title:
                        const Text('R4'),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(() {
                        selectedRole = value;
                      });
                    },
                  ),

                  if (isR5)
                    RadioListTile<String>(
                      value: 'R5',
                      groupValue:
                          selectedRole,
                      activeColor:
                          Colors.amber,
                      title:
                          const Text('R5'),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedRole =
                              value;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                      selectedRole,
                    );
                  },
                  child:
                      const Text('Weiter'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null ||
        result == user.role) {
      return;
    }

    await changeRole(
      user,
      result,
    );
  }

  Color roleColor(String role) {
    if (role == 'R5') {
      return Colors.amber;
    }

    if (role == 'R4') {
      return Colors.orangeAccent;
    }

    return Colors.white54;
  }

  IconData roleIcon(String role) {
    if (role == 'R5') {
      return Icons.workspace_premium;
    }

    if (role == 'R4') {
      return Icons.shield;
    }

    return Icons.person;
  }

  Widget statisticCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              const Color(0xFF1C1921),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber
                .withOpacity(0.16),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.amber,
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget memberCard(UserModel user) {
    final isMe =
        currentUser?.id == user.id;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      color:
          const Color(0xFF1C1921),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 9,
        ),
        leading: CircleAvatar(
          backgroundColor:
              Colors.amber
                  .withOpacity(0.15),
          child: Icon(
            roleIcon(user.role),
            color:
                roleColor(user.role),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.playerName.isEmpty
                    ? 'Unbekannter Spieler'
                    : user.playerName,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            if (isMe)
              Container(
                margin:
                    const EdgeInsets.only(
                  left: 6,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.amber
                      .withOpacity(0.15),
                  borderRadius:
                      BorderRadius
                          .circular(10),
                ),
                child:
                    const Text(
                  'DU',
                  style: TextStyle(
                    color:
                        Colors.amber,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            Text(
              user.alliance.isEmpty
                  ? 'Keine Allianz'
                  : user.alliance,
            ),

            if (user.discordName
                .isNotEmpty)
              Text(
                'Discord: ${user.discordName}',
              ),

            if (user.furnaceLevel > 0)
              Text(
                'Furnace ${user.furnaceLevel}',
              ),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: roleColor(
              user.role,
            ).withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Text(
            user.role == 'Member'
                ? 'Mitglied'
                : user.role,
            style: TextStyle(
              color:
                  roleColor(user.role),
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
        onTap: isMe
            ? null
            : () {
                showRoleDialog(user);
              },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor:
            Color(0xFF0F0D13),
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (!isLeadership) {
      return Scaffold(
        backgroundColor:
            const Color(0xFF0F0D13),
        appBar: AppBar(
          backgroundColor:
              const Color(0xFF0F0D13),
          title:
              const Text('👑 Leadership'),
        ),
        body: const Center(
          child: Padding(
            padding:
                EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.amber,
                ),
                SizedBox(height: 20),
                Text(
                  'Kein Zugriff',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Dieser Bereich ist nur für R4 und R5 verfügbar.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFF0F0D13),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F0D13),
        centerTitle: true,
        title: const Text(
          '👑 Leadership',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          StreamBuilder<List<UserModel>>(
        stream: watchUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Mitglieder konnten nicht geladen werden.\n${snapshot.error}',
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color:
                      Colors.redAccent,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final allUsers =
              snapshot.data!;

          final users =
              filterAndSortUsers(
            allUsers,
          );

          final r4Count = allUsers
              .where(
                (user) =>
                    user.role == 'R4',
              )
              .length;

          final r5Count = allUsers
              .where(
                (user) =>
                    user.role == 'R5',
              )
              .length;

          final furnaceUsers =
              allUsers
                  .where(
                    (user) =>
                        user.furnaceLevel >
                        0,
                  )
                  .toList();

          final averageFurnace =
              furnaceUsers.isEmpty
                  ? 0
                  : furnaceUsers
                          .fold<int>(
                            0,
                            (
                              sum,
                              user,
                            ) =>
                                sum +
                                user
                                    .furnaceLevel,
                          ) ~/
                      furnaceUsers.length;

          return ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons
                    .admin_panel_settings,
                size: 65,
                color: Colors.amber,
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  'LEADERSHIP CENTER',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  statisticCard(
                    value:
                        '${allUsers.length}',
                    label:
                        'Mitglieder',
                    icon: Icons.groups,
                  ),
                  const SizedBox(width: 8),
                  statisticCard(
                    value:
                        '$r4Count',
                    label: 'R4',
                    icon: Icons.shield,
                  ),
                  const SizedBox(width: 8),
                  statisticCard(
                    value:
                        '$r5Count',
                    label: 'R5',
                    icon: Icons
                        .workspace_premium,
                  ),
                  const SizedBox(width: 8),
                  statisticCard(
                    value:
                        '$averageFurnace',
                    label:
                        'Ø Furnace',
                    icon: Icons
                        .local_fire_department,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              TextField(
                controller:
                    searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Mitglied suchen...',
                  prefixIcon:
                      const Icon(
                    Icons.search,
                    color: Colors.amber,
                  ),
                  suffixIcon:
                      searchQuery.isEmpty
                          ? null
                          : IconButton(
                              onPressed:
                                  () {
                                searchController
                                    .clear();

                                setState(() {
                                  searchQuery =
                                      '';
                                });
                              },
                              icon:
                                  const Icon(
                                Icons.close,
                              ),
                            ),
                  filled: true,
                  fillColor:
                      const Color(
                    0xFF1C1921,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(18),
                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF1C1921,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<
                          String>(
                    value: sortMode,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'name',
                        child: Text(
                          'Sortieren: Name',
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            'furnace',
                        child: Text(
                          'Sortieren: Furnace',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'role',
                        child: Text(
                          'Sortieren: Rolle',
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        sortMode =
                            value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Text(
                    'Mitglieder',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${users.length}',
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

              const SizedBox(height: 12),

              if (users.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      'Keine Mitglieder gefunden.',
                      style: TextStyle(
                        color:
                            Colors.white54,
                      ),
                    ),
                  ),
                ),

              ...users.map(
                memberCard,
              ),

              const SizedBox(height: 30),

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(
                    0xFF1C1921,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(18),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rollen werden später zusätzlich durch Firebase Authentication und Firestore-Regeln abgesichert.',
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
      ),
    );
  }
}
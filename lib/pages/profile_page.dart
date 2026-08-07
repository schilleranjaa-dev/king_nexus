import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/device_service.dart';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final DeviceService _deviceService = DeviceService();

  final TextEditingController playerNameController =
      TextEditingController();

  final TextEditingController allianceController =
      TextEditingController();

  final TextEditingController discordController =
      TextEditingController();

  final TextEditingController furnaceController =
      TextEditingController();

  String role = 'Member';
  String? userId;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final id = await _deviceService.getOrCreateUserId();
      final profile = await _profileService.loadProfile(id);

      if (!mounted) return;

      userId = id;

      if (profile == null) {
        playerNameController.text = '';
        allianceController.text = 'SKS';
        discordController.text = '';
        furnaceController.text = '';
        role = 'Member';
      } else {
        playerNameController.text = profile.playerName;
        allianceController.text = profile.alliance;
        discordController.text = profile.discordName;
        furnaceController.text =
            profile.furnaceLevel == 0
                ? ''
                : profile.furnaceLevel.toString();

        role = profile.role;
      }

      setState(() {
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
            'Profil konnte nicht geladen werden: $e',
          ),
        ),
      );
    }
  }

  Future<void> saveProfile() async {
    if (userId == null) return;

    final playerName =
        playerNameController.text.trim();

    final alliance =
        allianceController.text.trim();

    final discord =
        discordController.text.trim();

    final furnaceLevel =
        int.tryParse(furnaceController.text.trim()) ?? 0;

    if (playerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte gib einen Spielernamen ein.',
          ),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    final user = UserModel(
      id: userId!,
      playerName: playerName,
      alliance: alliance,
      role: role,
      discordName: discord,
      furnaceLevel: furnaceLevel,
      isAdmin: role == 'R4' || role == 'R5',
    );

    try {
      await _profileService.saveProfile(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil wurde gespeichert.',
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

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: Colors.amber,
          ),
          filled: true,
          fillColor: const Color(0xFF1C1921),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget roleCard() {
    IconData roleIcon = Icons.person;
    String roleText = 'Mitglied';

    if (role == 'R4') {
      roleIcon = Icons.shield;
      roleText = 'R4';
    }

    if (role == 'R5') {
      roleIcon = Icons.workspace_premium;
      roleText = 'R5';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1921),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.amber.withOpacity(0.15),
            child: Icon(
              roleIcon,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rolle',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Die Rolle wird vom Leadership verwaltet.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
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
  void dispose() {
    playerNameController.dispose();
    allianceController.dispose();
    discordController.dispose();
    furnaceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0D13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0D13),
        centerTitle: true,
        title: const Text(
          '👤 Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
                  child: CircleAvatar(
                    radius: 58,
                    backgroundColor: Colors.amber,
                    child: Icon(
                      Icons.person,
                      size: 68,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                inputField(
                  controller: playerNameController,
                  label: 'Spielername',
                  icon: Icons.person,
                ),

                inputField(
                  controller: allianceController,
                  label: 'Allianz',
                  icon: Icons.shield,
                ),

                inputField(
                  controller: discordController,
                  label: 'Discord-Name',
                  icon: Icons.chat,
                ),

                inputField(
                  controller: furnaceController,
                  label: 'Furnace Level',
                  icon: Icons.local_fire_department,
                  keyboardType: TextInputType.number,
                ),

                roleCard(),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        isSaving ? null : saveProfile,
                    icon: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.cloud_upload,
                          ),
                    label: Text(
                      isSaving
                          ? 'Speichere...'
                          : 'Profil speichern',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Deine Rolle kannst du nicht selbst ändern.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
    );
  }
}
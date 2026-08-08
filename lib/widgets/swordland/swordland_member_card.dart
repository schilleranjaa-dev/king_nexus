import 'package:flutter/material.dart';

import '../../models/event_registration_model.dart';

class SwordlandMemberCard extends StatelessWidget {
  final EventRegistrationModel member;
  final bool canManage;
  final VoidCallback? onTap;

  const SwordlandMemberCard({
    super.key,
    required this.member,
    required this.canManage,
    required this.onTap,
  });

  String get displayRole {
    if (member.role == 'Member') {
      return 'Mitglied';
    }

    return member.role;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canManage ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(
            top: 8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF151219),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    Colors.amber.withOpacity(0.14),
                child: const Icon(
                  Icons.person,
                  color: Colors.amber,
                  size: 19,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.playerName.isEmpty
                          ? 'Unbekannter Spieler'
                          : member.playerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '${member.alliance} • $displayRole',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (canManage)
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color:
                        Colors.amber.withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
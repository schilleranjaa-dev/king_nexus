import 'package:flutter/material.dart';

import '../../models/event_group_model.dart';

class SwordlandRegistrationCard extends StatelessWidget {
  final EventGroupModel group;

  final bool selected;
  final bool isFull;
  final bool isSaving;

  final int currentPlayers;

  final VoidCallback? onTap;

  const SwordlandRegistrationCard({
    super.key,
    required this.group,
    required this.selected,
    required this.isFull,
    required this.isSaving,
    required this.currentPlayers,
    required this.onTap,
  });

  IconData get groupIcon {
    switch (group.id) {
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

  String get capacityText {
    if (group.maxPlayers <= 0) {
      return '$currentPlayers';
    }

    return '$currentPlayers / ${group.maxPlayers}';
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        isSaving ||
        (isFull && !selected);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? Colors.amber.withOpacity(0.16)
              : const Color(0xFF1C1921),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.amber
                : isFull
                    ? Colors.redAccent.withOpacity(0.65)
                    : Colors.amber.withOpacity(0.18),
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  Colors.amber.withOpacity(0.15),
              child: Icon(
                groupIcon,
                color: Colors.amber,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isFull &&
                          group.maxPlayers > 0)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent
                                .withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'VOLL',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    group.description,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.groups,
                        size: 17,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 6),

                      Text(
                        capacityText,
                        style: TextStyle(
                          color: isFull &&
                                  group.maxPlayers > 0
                              ? Colors.redAccent
                              : Colors.white70,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      if (group.maxPlayers > 0) ...[
                        const SizedBox(width: 7),
                        Text(
                          group.id.startsWith(
                            'reserve_',
                          )
                              ? 'Ersatzplätze'
                              : 'Plätze',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.amber,
                size: 27,
              )
            else if (isFull &&
                group.maxPlayers > 0)
              const Icon(
                Icons.lock,
                color: Colors.redAccent,
              )
            else
              const Icon(
                Icons.chevron_right,
                color: Colors.white38,
              ),
          ],
        ),
      ),
    );
  }
}
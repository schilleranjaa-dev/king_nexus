import 'package:flutter/material.dart';

import '../../models/event_group_model.dart';
import '../../models/event_registration_model.dart';

class SwordlandMoveMemberDialog extends StatefulWidget {
  final EventRegistrationModel member;
  final List<EventGroupModel> groups;
  final List<EventRegistrationModel> registrations;

  const SwordlandMoveMemberDialog({
    super.key,
    required this.member,
    required this.groups,
    required this.registrations,
  });

  @override
  State<SwordlandMoveMemberDialog> createState() =>
      _SwordlandMoveMemberDialogState();
}

class _SwordlandMoveMemberDialogState
    extends State<SwordlandMoveMemberDialog> {
  late String selectedGroupId;

  @override
  void initState() {
    super.initState();
    selectedGroupId = widget.member.selection;
  }

  int playerCount(String groupId) {
    return widget.registrations
        .where(
          (registration) =>
              registration.selection == groupId,
        )
        .length;
  }

  bool isFull(EventGroupModel group) {
    if (group.maxPlayers <= 0) {
      return false;
    }

    final count = playerCount(group.id);

    final memberAlreadyInGroup =
        widget.member.selection == group.id;

    if (memberAlreadyInGroup) {
      return false;
    }

    return count >= group.maxPlayers;
  }

  String capacityText(EventGroupModel group) {
    final count = playerCount(group.id);

    if (group.maxPlayers <= 0) {
      return '$count';
    }

    return '$count / ${group.maxPlayers}';
  }

  IconData groupIcon(String groupId) {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1921),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spieler verschieben',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.member.playerName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.groups.map(
              (group) {
                final full = isFull(group);

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151219),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedGroupId == group.id
                          ? Colors.amber
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: group.id,
                    groupValue: selectedGroupId,
                    activeColor: Colors.amber,
                    onChanged: full
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              selectedGroupId = value;
                            });
                          },
                    secondary: Icon(
                      full
                          ? Icons.lock
                          : groupIcon(group.id),
                      color: full
                          ? Colors.redAccent
                          : Colors.amber,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: full
                                  ? Colors.white38
                                  : Colors.white,
                            ),
                          ),
                        ),

                        if (full)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent
                                  .withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VOLL',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      capacityText(group),
                      style: TextStyle(
                        color: full
                            ? Colors.redAccent
                            : Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Abbrechen',
          ),
        ),

        ElevatedButton.icon(
          onPressed: selectedGroupId ==
                  widget.member.selection
              ? null
              : () {
                  Navigator.pop(
                    context,
                    selectedGroupId,
                  );
                },
          icon: const Icon(
            Icons.swap_horiz,
          ),
          label: const Text(
            'Verschieben',
          ),
        ),
      ],
    );
  }
}
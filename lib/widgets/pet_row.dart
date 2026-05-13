import 'package:flutter/material.dart';

import '../models/health_record.dart';
import '../models/pet.dart';
import '../models/enums.dart';
import '../l10n/app_localizations.dart';

class PetRow extends StatelessWidget {
  final Pet pet;
  final List<HealthRecord> records;

  const PetRow({super.key, required this.pet, required this.records});

  int get pendingCount {
    final now = DateTime.now();
    return records
        .where((r) => r.nextDueDate != null && !r.nextDueDate!.isBefore(now))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bg = pet.species == Species.dog
        ? Colors.orange.withValues(alpha: 0.15)
        : Colors.purple.withValues(alpha: 0.15);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(pet.species.icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${pet.breed} · ${pet.ageLabel(l)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('$pendingCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

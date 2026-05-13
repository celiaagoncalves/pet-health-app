import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/health_record.dart';

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onDelete;

  const HealthRecordCard({
    super.key,
    required this.record,
    required this.onDelete,
  });

  bool get isOverdue =>
      record.nextDueDate != null && record.nextDueDate!.isBefore(DateTime.now());

  bool get isDueSoon {
    if (record.nextDueDate == null || isOverdue) return false;
    final diff = record.nextDueDate!.difference(DateTime.now()).inDays;
    return diff <= 7;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final df = DateFormat.yMd(Localizations.localeOf(context).toString());

    return GestureDetector(
      onLongPress: () => _showDeleteSheet(context, l),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(record.type.icon, color: record.type.accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.name,
                          style:
                              Theme.of(context).textTheme.titleMedium),
                      Text(record.type.label(l),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(df.format(record.date),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Text(record.notes,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey)),
              ),
            ],
            if (record.nextDueDate != null) ...[
              const SizedBox(height: 10),
              const Divider(),
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.error
                        : isDueSoon
                            ? Icons.access_time
                            : Icons.calendar_today,
                    size: 16,
                    color: isOverdue
                        ? Colors.red
                        : isDueSoon
                            ? Colors.orange
                            : Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  Text(l.petDetailRecordNext,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  Text(df.format(record.nextDueDate!),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (isOverdue)
                    _badge(l.petDetailStatusOverdue, Colors.red)
                  else if (isDueSoon)
                    _badge(l.petDetailStatusDueSoon, Colors.orange),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }

  void _showDeleteSheet(BuildContext context, AppLocalizations l) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: Text(l.petDetailRecordDelete,
              style: const TextStyle(color: Colors.red)),
          onTap: () {
            Navigator.pop(ctx);
            onDelete();
          },
        ),
      ),
    );
  }
}
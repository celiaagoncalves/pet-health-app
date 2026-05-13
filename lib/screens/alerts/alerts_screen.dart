import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/health_record.dart';
import '../../models/pet.dart';
import '../../services/database_service.dart';

class _AlertItem {
  final Pet pet;
  final HealthRecord record;
  _AlertItem(this.pet, this.record);

  DateTime get dueDate => record.nextDueDate!;
  bool get isOverdue => dueDate.isBefore(DateTime.now());
  int get daysUntilDue =>
      dueDate.difference(DateTime.now()).inDays;
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final db = DatabaseService.instance;

    return Scaffold(
      appBar: AppBar(title: Text(l.alertsTitle)),
      body: ValueListenableBuilder<Box<HealthRecord>>(
        valueListenable: db.recordsBox.listenable(),
        builder: (context, _, __) {
          final pets = {for (final p in db.allPets()) p.id: p};
          final all = db.recordsBox.values
              .where((r) => r.nextDueDate != null && pets.containsKey(r.petId))
              .map((r) => _AlertItem(pets[r.petId]!, r))
              .toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

          if (all.isEmpty) return _emptyState(context, l);

          final overdue = all.where((a) => a.isOverdue).toList();
          final upcoming = all.where((a) => !a.isOverdue).toList();

          return ListView(
            children: [
              if (overdue.isNotEmpty) ...[
                _sectionHeader(
                    l.alertsSectionOverdue, Icons.error, Colors.red),
                ...overdue.map((a) => _AlertRow(item: a)),
              ],
              if (upcoming.isNotEmpty) ...[
                _sectionHeader(l.alertsSectionUpcoming, null, Colors.grey),
                ...upcoming.map((a) => _AlertRow(item: a)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, IconData? icon, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
          ],
          Text(title.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 56, color: Colors.green),
            const SizedBox(height: 16),
            Text(l.alertsEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.alertsEmptySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final _AlertItem item;
  const _AlertRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final df = DateFormat.yMd(Localizations.localeOf(context).toString());

    final statusColor = item.isOverdue
        ? Colors.red
        : item.daysUntilDue <= 7
            ? Colors.orange
            : Colors.blue;

    final String statusLabel;
    if (item.isOverdue) {
      final days = item.daysUntilDue.abs();
      statusLabel =
          days == 0 ? l.commonToday : l.alertsDaysAgo(days);
    } else {
      statusLabel = item.daysUntilDue == 0
          ? l.commonToday
          : l.alertsDaysUntil(item.daysUntilDue);
    }

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(item.record.type.icon, color: item.record.type.accentColor),
      ),
      title: Text(item.record.name),
      subtitle: Row(
        children: [
          Text(item.pet.species.icon),
          const SizedBox(width: 4),
          Text(item.pet.name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const Text(' · '),
          Text(item.record.type.label(l)),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(statusLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          Text(df.format(item.dueDate),
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
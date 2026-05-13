import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/health_record.dart';
import '../../models/pet.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/pet_row.dart';
import 'add_edit_pet_screen.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final db = DatabaseService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.petsTitle),
        actions: [
          IconButton(
            icon: Icon(_showArchived
                ? Icons.visibility
                : Icons.visibility_off_outlined),
            tooltip: l.petsShowArchived,
            onPressed: () =>
                setState(() => _showArchived = !_showArchived),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddPet(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Pet>>(
        valueListenable: db.petsBox.listenable(),
        builder: (context, box, _) {
          final allPets = db.allPets();
          if (allPets.isEmpty) return _emptyState(context, l);

          final alive =
              allPets.where((p) => p.status == PetStatus.alive).toList();
          final inactive =
              allPets.where((p) => p.status != PetStatus.alive).toList();

          return ListView(
            children: [
              for (final species in Species.values)
                _section(
                  l,
                  species.section(l),
                  alive.where((p) => p.species == species).toList(),
                ),
              if (_showArchived && inactive.isNotEmpty)
                _section(l, l.petsSectionDeceasedArchived, inactive,
                    isInactive: true),
            ],
          );
        },
      ),
    );
  }

  Widget _section(AppLocalizations l, String title, List<Pet> items,
      {bool isInactive = false}) {
    if (items.isEmpty) return const SizedBox.shrink();
    final db = DatabaseService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title,
              style: TextStyle(
                  color: isInactive ? Colors.grey : Colors.grey.shade600,
                  letterSpacing: 0.5,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        ...items.map((pet) {
          final records = db.recordsFor(pet.id);
          return Dismissible(
            key: ValueKey(pet.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deletePet(pet, records),
            child: Opacity(
              opacity: isInactive ? 0.55 : 1.0,
              child: ListTile(
                title: PetRow(pet: pet, records: records),
                trailing: pet.status != PetStatus.alive
                    ? Icon(pet.status.icon,
                        size: 18, color: pet.status.color)
                    : const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PetDetailScreen(pet: pet)),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, size: 64, color: Colors.grey),
            const SizedBox(height: 20),
            Text(l.petsEmptyTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l.petsEmptySubtitle,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _openAddPet(context),
              icon: const Icon(Icons.add),
              label: Text(l.petsEmptyButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePet(Pet pet, List<HealthRecord> records) async {
    for (final r in records) {
      await NotificationService.instance.cancel(r);
    }
    await DatabaseService.instance.deletePet(pet);
  }

  void _openAddPet(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AddEditPetScreen(),
      ),
    );
  }
}

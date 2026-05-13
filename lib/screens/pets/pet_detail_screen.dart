import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/health_record.dart';
import '../../models/pet.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/filter_chip_button.dart';
import '../../widgets/health_record_card.dart';
import '../../widgets/stat_card.dart';
import '../health/add_health_record_screen.dart';
import 'add_edit_pet_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  HealthRecordType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final db = DatabaseService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) =>
                            AddEditPetScreen(pet: widget.pet)));
              } else if (v == 'record') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) =>
                            AddHealthRecordScreen(pet: widget.pet)));
              } else if (v == 'status') {
                _showStatusSheet(context, l);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit, size: 18),
                  const SizedBox(width: 8),
                  Text(l.petDetailMenuEdit),
                ]),
              ),
              PopupMenuItem(
                value: 'record',
                child: Row(children: [
                  const Icon(Icons.add, size: 18),
                  const SizedBox(width: 8),
                  Text(l.petDetailMenuAddRecord),
                ]),
              ),
              PopupMenuItem(
                value: 'status',
                child: Row(children: [
                  Icon(widget.pet.status.icon,
                      size: 18, color: widget.pet.status.color),
                  const SizedBox(width: 8),
                  Text(l.petDetailMenuChangeStatus),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<HealthRecord>>(
        valueListenable: db.recordsBox.listenable(),
        builder: (context, _, __) {
          final allRecords = db.recordsFor(widget.pet.id);
          final filtered = _selectedType == null
              ? allRecords
              : allRecords.where((r) => r.type == _selectedType).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                _header(context, l),
                if (widget.pet.status != PetStatus.alive) _statusBanner(l),
                const SizedBox(height: 16),
                _statsRow(allRecords, l),
                const SizedBox(height: 20),
                _cadernetaSections(l),
                const SizedBox(height: 8),
                _filterChips(l),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  _emptyRecords(context, l)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: filtered
                          .map((r) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: HealthRecordCard(
                                  record: r,
                                  onDelete: () => _deleteRecord(r),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l) {
    final pet = widget.pet;
    final bg = pet.species.accentColor.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(pet.species.icon,
                style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 12),
          Text(pet.name,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children: [
              Icon(pet.gender.icon, size: 16, color: Colors.grey),
              Text(pet.gender.label(l),
                  style: const TextStyle(color: Colors.grey)),
              const Text('·', style: TextStyle(color: Colors.grey)),
              Text(pet.displaySpecies(l),
                  style: const TextStyle(color: Colors.grey)),
              const Text('·', style: TextStyle(color: Colors.grey)),
              Text(pet.breed,
                  style: const TextStyle(color: Colors.grey)),
              const Text('·', style: TextStyle(color: Colors.grey)),
              Text(pet.ageLabel(l),
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoItem(l.petDetailColor,
                    pet.color.isEmpty ? l.commonDash : pet.color),
                Container(
                    width: 1, height: 32, color: Colors.grey.shade300),
                _infoItem(l.petDetailCoat, pet.coatType.label(l)),
                if (pet.weightKg != null) ...[
                  Container(
                      width: 1, height: 32, color: Colors.grey.shade300),
                  _infoItem(l.petFormWeight,
                      '${pet.weightKg!.toStringAsFixed(1)} kg'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(AppLocalizations l) {
    final pet = widget.pet;
    final df = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    String text;
    if (pet.status == PetStatus.deceased) {
      text = pet.deathDate != null
          ? l.petDetailDeceasedOn(df.format(pet.deathDate!))
          : pet.status.label(l);
    } else {
      text = pet.status.label(l);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: pet.status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(pet.status.icon, color: pet.status.color, size: 18),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: pet.status.color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _statsRow(List<HealthRecord> records, AppLocalizations l) {
    final vaccines =
        records.where((r) => r.type == HealthRecordType.vaccine).length;
    final deworming =
        records.where((r) => r.type == HealthRecordType.deworming).length;
    final alerts = records
        .where((r) =>
            r.nextDueDate != null && !r.nextDueDate!.isBefore(DateTime.now()))
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          StatCard(
              icon: Icons.vaccines,
              color: Colors.blue,
              title: l.petDetailStatsVaccines,
              count: vaccines),
          const SizedBox(width: 12),
          StatCard(
              icon: Icons.healing,
              color: Colors.green,
              title: l.petDetailStatsDeworming,
              count: deworming),
          const SizedBox(width: 12),
          StatCard(
              icon: Icons.notifications,
              color: Colors.orange,
              title: l.petDetailStatsAlerts,
              count: alerts),
        ],
      ),
    );
  }

  Widget _cadernetaSections(AppLocalizations l) {
    final pet = widget.pet;
    final idItems = <_KV>[
      if (pet.microchip?.isNotEmpty == true)
        _KV(l.petFormMicrochip, pet.microchip!),
      if (pet.insuranceCompany?.isNotEmpty == true)
        _KV(l.petFormInsurance, pet.insuranceCompany!),
      if (pet.insurancePolicy?.isNotEmpty == true)
        _KV(l.petFormInsurancePolicy, pet.insurancePolicy!),
    ];
    final vetItems = <_KV>[
      if (pet.vetName?.isNotEmpty == true)
        _KV(l.petFormVetName, pet.vetName!),
      if (pet.vetPhone?.isNotEmpty == true)
        _KV(l.petFormVetPhone, pet.vetPhone!),
    ];
    final healthItems = <_KV>[
      if (pet.isSterilized != null)
        _KV(l.petFormSterilized, pet.isSterilized! ? l.commonYes : l.commonNo),
      if (pet.allergies?.isNotEmpty == true)
        _KV(l.petFormAllergies, pet.allergies!),
      if (pet.medicalConditions?.isNotEmpty == true)
        _KV(l.petFormMedicalConditions, pet.medicalConditions!),
    ];

    return Column(
      children: [
        if (idItems.isNotEmpty)
          _CadernetaCard(title: l.petDetailSectionId, items: idItems),
        if (vetItems.isNotEmpty)
          _CadernetaCard(title: l.petDetailSectionVet, items: vetItems),
        if (healthItems.isNotEmpty)
          _CadernetaCard(title: l.petDetailSectionHealth, items: healthItems),
      ],
    );
  }

  Widget _filterChips(AppLocalizations l) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChipButton(
            title: l.petDetailFilterAll,
            isSelected: _selectedType == null,
            onTap: () => setState(() => _selectedType = null),
          ),
          ...HealthRecordType.values.map((t) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChipButton(
                  title: t.label(l),
                  isSelected: _selectedType == t,
                  onTap: () => setState(
                      () => _selectedType = _selectedType == t ? null : t),
                ),
              )),
        ],
      ),
    );
  }

  Widget _emptyRecords(BuildContext context, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Icon(Icons.favorite_border, size: 40, color: Colors.grey),
          const SizedBox(height: 12),
          Text(l.petDetailRecordsEmpty,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) =>
                      AddHealthRecordScreen(pet: widget.pet)),
            ),
            child: Text(l.petDetailRecordsAdd),
          ),
        ],
      ),
    );
  }

  Future<void> _showStatusSheet(BuildContext context, AppLocalizations l) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(l.statusChangeTitle,
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              ...PetStatus.values.map((s) => ListTile(
                    leading: Icon(s.icon, color: s.color),
                    title: Text(s.label(l)),
                    trailing: widget.pet.status == s
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _changeStatus(s);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeStatus(PetStatus newStatus) async {
    if (newStatus == PetStatus.deceased) {
      final picked = await showDatePicker(
        context: context,
        initialDate: widget.pet.deathDate ?? DateTime.now(),
        firstDate: widget.pet.birthDate,
        lastDate: DateTime.now(),
        helpText:
            AppLocalizations.of(context).statusDeathDate.toUpperCase(),
      );
      if (picked == null) return;
      widget.pet.deathDate = picked;
    } else {
      widget.pet.deathDate = null;
    }
    widget.pet.status = newStatus;
    await DatabaseService.instance.savePet(widget.pet);
    if (mounted) setState(() {});
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    await NotificationService.instance.cancel(record);
    await DatabaseService.instance.deleteRecord(record);
  }
}

class _KV {
  final String label;
  final String value;
  _KV(this.label, this.value);
}

class _CadernetaCard extends StatelessWidget {
  final String title;
  final List<_KV> items;
  const _CadernetaCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...items.map((kv) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(kv.label,
                            style:
                                const TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(kv.value,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

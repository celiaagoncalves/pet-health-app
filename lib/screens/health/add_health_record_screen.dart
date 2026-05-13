import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/health_record.dart';
import '../../models/pet.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final Pet pet;
  const AddHealthRecordScreen({super.key, required this.pet});

  @override
  State<AddHealthRecordScreen> createState() =>
      _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  HealthRecordType _type = HealthRecordType.vaccine;
  final _name = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  bool _hasNextDue = false;
  DateTime _nextDueDate =
      DateTime.now().add(const Duration(days: 365));
  bool _scheduleNotification = true;

  bool get _isValid => _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.recordFormTitle(widget.pet.name)),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: _isValid ? _save : null,
            child: Text(l.commonSave,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(l.recordFormSectionType),
          DropdownButtonFormField<HealthRecordType>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l.recordFormType),
            items: HealthRecordType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Row(children: [
                        Icon(t.icon, size: 18, color: t.accentColor),
                        const SizedBox(width: 8),
                        Text(t.label(l)),
                      ]),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 24),
          _sectionTitle(l.recordFormSectionDetails),
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: _type.placeholder(l)),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.recordFormDate),
            subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(isNext: false),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: InputDecoration(labelText: l.recordFormNotes),
            maxLines: 4,
            minLines: 3,
          ),
          const SizedBox(height: 24),
          _sectionTitle(l.recordFormSectionNext),
          SwitchListTile(
            title: Text(l.recordFormToggleHasNext),
            contentPadding: EdgeInsets.zero,
            value: _hasNextDue,
            onChanged: (v) => setState(() => _hasNextDue = v),
          ),
          if (_hasNextDue) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.recordFormNextDate),
              subtitle: Text(
                  '${_nextDueDate.day}/${_nextDueDate.month}/${_nextDueDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isNext: true),
            ),
            SwitchListTile(
              title: Text(l.recordFormToggleNotify),
              contentPadding: EdgeInsets.zero,
              value: _scheduleNotification,
              onChanged: (v) => setState(() => _scheduleNotification = v),
            ),
            if (_scheduleNotification)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l.recordFormFooterNotify,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _pickDate({required bool isNext}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isNext ? _nextDueDate : _date,
      firstDate: isNext ? DateTime.now() : DateTime(1990),
      lastDate: isNext ? DateTime(2100) : DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isNext) {
          _nextDueDate = picked;
        } else {
          _date = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    final record = HealthRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      name: _name.text.trim(),
      date: _date,
      notes: _notes.text.trim(),
      nextDueDate: _hasNextDue ? _nextDueDate : null,
      petId: widget.pet.id,
    );

    await DatabaseService.instance.saveRecord(record);

    if (_hasNextDue && _scheduleNotification && mounted) {
      await NotificationService.instance.schedule(
        record: record,
        petName: widget.pet.name,
        type: _type,
        date: _nextDueDate,
        l: AppLocalizations.of(context),
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
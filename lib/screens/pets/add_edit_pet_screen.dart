import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/enums.dart';
import '../../models/pet.dart';
import '../../services/database_service.dart';

class AddEditPetScreen extends StatefulWidget {
  final Pet? pet;
  const AddEditPetScreen({super.key, this.pet});

  @override
  State<AddEditPetScreen> createState() => _AddEditPetScreenState();
}

class _AddEditPetScreenState extends State<AddEditPetScreen> {
  // Required
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _color;
  late final TextEditingController _customSpecies;
  late Species _species;
  late DateTime _birthDate;
  late Gender _gender;
  late CoatType _coatType;

  // Caderneta
  late final TextEditingController _microchip;
  late final TextEditingController _insuranceCompany;
  late final TextEditingController _insurancePolicy;
  late final TextEditingController _vetName;
  late final TextEditingController _vetPhone;
  late final TextEditingController _weight;
  late final TextEditingController _allergies;
  late final TextEditingController _medicalConditions;
  bool? _isSterilized;

  bool get _isEditing => widget.pet != null;

  bool get _isValid {
    if (_name.text.trim().isEmpty || _breed.text.trim().isEmpty) return false;
    if (_species == Species.other && _customSpecies.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.pet;
    _name = TextEditingController(text: p?.name ?? '');
    _breed = TextEditingController(text: p?.breed ?? '');
    _color = TextEditingController(text: p?.color ?? '');
    _customSpecies = TextEditingController(text: p?.customSpecies ?? '');
    _species = p?.species ?? Species.dog;
    _birthDate = p?.birthDate ?? DateTime.now();
    _gender = p?.gender ?? Gender.male;
    _coatType = p?.coatType ?? CoatType.short;

    _microchip = TextEditingController(text: p?.microchip ?? '');
    _insuranceCompany = TextEditingController(text: p?.insuranceCompany ?? '');
    _insurancePolicy = TextEditingController(text: p?.insurancePolicy ?? '');
    _vetName = TextEditingController(text: p?.vetName ?? '');
    _vetPhone = TextEditingController(text: p?.vetPhone ?? '');
    _weight = TextEditingController(
        text: p?.weightKg != null ? p!.weightKg!.toString() : '');
    _allergies = TextEditingController(text: p?.allergies ?? '');
    _medicalConditions =
        TextEditingController(text: p?.medicalConditions ?? '');
    _isSterilized = p?.isSterilized;
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _color.dispose();
    _customSpecies.dispose();
    _microchip.dispose();
    _insuranceCompany.dispose();
    _insurancePolicy.dispose();
    _vetName.dispose();
    _vetPhone.dispose();
    _weight.dispose();
    _allergies.dispose();
    _medicalConditions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.petFormTitleEdit : l.petFormTitleNew),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.commonCancel),
        ),
        leadingWidth: 100,
        actions: [
          TextButton(
            onPressed: _isValid ? _save : null,
            child: Text(_isEditing ? l.commonSave : l.commonAdd,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle(l.petFormSectionSpecies),
          DropdownButtonFormField<Species>(
            initialValue: _species,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: Species.values
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text('${s.icon}  ${s.label(l)}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _species = v!),
          ),
          if (_species == Species.other) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _customSpecies,
              decoration: InputDecoration(
                  labelText: l.petFormCustomSpecies,
                  border: const OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 24),

          _sectionTitle(l.petFormSectionBasics),
          TextField(
            controller: _name,
            decoration: InputDecoration(
                labelText: l.petFormName,
                border: const OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _breed,
            decoration: InputDecoration(
                labelText: l.petFormBreed,
                border: const OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.petFormBirthDate),
            subtitle: Text(
                '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 16),

          _sectionTitle(l.petFormSectionFeatures),
          DropdownButtonFormField<Gender>(
            initialValue: _gender,
            decoration: InputDecoration(
                labelText: l.petFormGender,
                border: const OutlineInputBorder()),
            items: Gender.values
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Row(children: [
                        Icon(g.icon, size: 18),
                        const SizedBox(width: 8),
                        Text(g.label(l)),
                      ]),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _color,
            decoration: InputDecoration(
                labelText: l.petFormColor,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CoatType>(
            initialValue: _coatType,
            decoration: InputDecoration(
                labelText: l.petFormCoatType,
                border: const OutlineInputBorder()),
            items: CoatType.values
                .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c.label(l))))
                .toList(),
            onChanged: (v) => setState(() => _coatType = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weight,
            decoration: InputDecoration(
                labelText: l.petFormWeight,
                border: const OutlineInputBorder()),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 24),

          _sectionTitle(l.petFormSectionId),
          TextField(
            controller: _microchip,
            decoration: InputDecoration(
                labelText: l.petFormMicrochip,
                border: const OutlineInputBorder()),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _insuranceCompany,
            decoration: InputDecoration(
                labelText: l.petFormInsurance,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _insurancePolicy,
            decoration: InputDecoration(
                labelText: l.petFormInsurancePolicy,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 24),

          _sectionTitle(l.petFormSectionVet),
          TextField(
            controller: _vetName,
            decoration: InputDecoration(
                labelText: l.petFormVetName,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _vetPhone,
            decoration: InputDecoration(
                labelText: l.petFormVetPhone,
                border: const OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          _sectionTitle(l.petFormSectionHealth),
          SwitchListTile(
            title: Text(l.petFormSterilized),
            contentPadding: EdgeInsets.zero,
            value: _isSterilized ?? false,
            onChanged: (v) => setState(() => _isSterilized = v),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _allergies,
            decoration: InputDecoration(
                labelText: l.petFormAllergies,
                border: const OutlineInputBorder()),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _medicalConditions,
            decoration: InputDecoration(
                labelText: l.petFormMedicalConditions,
                border: const OutlineInputBorder()),
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  double? _parseWeight() {
    final raw = _weight.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  String? _trimmedOrNull(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _save() async {
    final existing = widget.pet;
    if (existing != null) {
      existing.name = _name.text.trim();
      existing.species = _species;
      existing.customSpecies =
          _species == Species.other ? _customSpecies.text.trim() : null;
      existing.birthDate = _birthDate;
      existing.breed = _breed.text.trim();
      existing.gender = _gender;
      existing.color = _color.text.trim();
      existing.coatType = _coatType;
      existing.microchip = _trimmedOrNull(_microchip);
      existing.insuranceCompany = _trimmedOrNull(_insuranceCompany);
      existing.insurancePolicy = _trimmedOrNull(_insurancePolicy);
      existing.vetName = _trimmedOrNull(_vetName);
      existing.vetPhone = _trimmedOrNull(_vetPhone);
      existing.weightKg = _parseWeight();
      existing.isSterilized = _isSterilized;
      existing.allergies = _trimmedOrNull(_allergies);
      existing.medicalConditions = _trimmedOrNull(_medicalConditions);
      await DatabaseService.instance.savePet(existing);
    } else {
      final pet = Pet(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        species: _species,
        customSpecies:
            _species == Species.other ? _customSpecies.text.trim() : null,
        birthDate: _birthDate,
        breed: _breed.text.trim(),
        gender: _gender,
        color: _color.text.trim(),
        coatType: _coatType,
        microchip: _trimmedOrNull(_microchip),
        insuranceCompany: _trimmedOrNull(_insuranceCompany),
        insurancePolicy: _trimmedOrNull(_insurancePolicy),
        vetName: _trimmedOrNull(_vetName),
        vetPhone: _trimmedOrNull(_vetPhone),
        weightKg: _parseWeight(),
        isSterilized: _isSterilized,
        allergies: _trimmedOrNull(_allergies),
        medicalConditions: _trimmedOrNull(_medicalConditions),
      );
      await DatabaseService.instance.savePet(pet);
    }
    if (mounted) Navigator.pop(context);
  }
}

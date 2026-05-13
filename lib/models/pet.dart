import 'package:hive/hive.dart';

import '../l10n/app_localizations.dart';
import 'enums.dart';

class Pet extends HiveObject {
  String id;
  String name;
  Species species;
  String? customSpecies;
  DateTime birthDate;
  String breed;
  Gender gender;
  String color;
  CoatType coatType;

  // Status
  PetStatus status;
  DateTime? deathDate;

  // Caderneta — identification
  String? microchip;
  String? insuranceCompany;
  String? insurancePolicy;

  // Caderneta — veterinarian
  String? vetName;
  String? vetPhone;

  // Caderneta — health
  double? weightKg;
  bool? isSterilized;
  String? allergies;
  String? medicalConditions;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.customSpecies,
    required this.birthDate,
    required this.breed,
    required this.gender,
    this.color = '',
    required this.coatType,
    this.status = PetStatus.alive,
    this.deathDate,
    this.microchip,
    this.insuranceCompany,
    this.insurancePolicy,
    this.vetName,
    this.vetPhone,
    this.weightKg,
    this.isSterilized,
    this.allergies,
    this.medicalConditions,
  });

  String displaySpecies(AppLocalizations l) {
    if (species == Species.other && customSpecies?.isNotEmpty == true) {
      return customSpecies!;
    }
    return species.label(l);
  }

  String ageLabel(AppLocalizations l) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
    if (!birth.isBefore(today)) return l.ageNewborn;

    var years = today.year - birth.year;
    var months = today.month - birth.month;
    var days = today.day - birth.day;

    if (days < 0) {
      months--;
      days += DateTime(today.year, today.month, 0).day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) return l.ageYears(years);
    if (months > 0) return l.ageMonths(months);
    if (days > 0) return l.ageDays(days);
    return l.ageNewborn;
  }
}

class PetAdapter extends TypeAdapter<Pet> {
  @override
  final int typeId = 11;

  String? _nullable(BinaryReader reader) {
    final s = reader.readString();
    return s.isEmpty ? null : s;
  }

  void _writeNullable(BinaryWriter writer, String? value) {
    writer.writeString(value ?? '');
  }

  @override
  Pet read(BinaryReader reader) {
    return Pet(
      id: reader.readString(),
      name: reader.readString(),
      species: Species.values[reader.readByte()],
      customSpecies: _nullable(reader),
      birthDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      breed: reader.readString(),
      gender: Gender.values[reader.readByte()],
      color: reader.readString(),
      coatType: CoatType.values[reader.readByte()],
      status: PetStatus.values[reader.readByte()],
      deathDate: reader.readBool()
          ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
          : null,
      microchip: _nullable(reader),
      insuranceCompany: _nullable(reader),
      insurancePolicy: _nullable(reader),
      vetName: _nullable(reader),
      vetPhone: _nullable(reader),
      weightKg: reader.readBool() ? reader.readDouble() : null,
      isSterilized: reader.readBool() ? reader.readBool() : null,
      allergies: _nullable(reader),
      medicalConditions: _nullable(reader),
    );
  }

  @override
  void write(BinaryWriter writer, Pet obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeByte(obj.species.index);
    _writeNullable(writer, obj.customSpecies);
    writer.writeInt(obj.birthDate.millisecondsSinceEpoch);
    writer.writeString(obj.breed);
    writer.writeByte(obj.gender.index);
    writer.writeString(obj.color);
    writer.writeByte(obj.coatType.index);
    writer.writeByte(obj.status.index);
    writer.writeBool(obj.deathDate != null);
    if (obj.deathDate != null) {
      writer.writeInt(obj.deathDate!.millisecondsSinceEpoch);
    }
    _writeNullable(writer, obj.microchip);
    _writeNullable(writer, obj.insuranceCompany);
    _writeNullable(writer, obj.insurancePolicy);
    _writeNullable(writer, obj.vetName);
    _writeNullable(writer, obj.vetPhone);
    writer.writeBool(obj.weightKg != null);
    if (obj.weightKg != null) writer.writeDouble(obj.weightKg!);
    writer.writeBool(obj.isSterilized != null);
    if (obj.isSterilized != null) writer.writeBool(obj.isSterilized!);
    _writeNullable(writer, obj.allergies);
    _writeNullable(writer, obj.medicalConditions);
  }
}

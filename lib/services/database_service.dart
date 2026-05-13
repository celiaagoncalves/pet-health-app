import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_record.dart';
import '../models/pet.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String petsBoxName = 'pets';
  static const String recordsBoxName = 'health_records';
  static const String _schemaKey = 'hive_schema_version';
  static const int _currentSchemaVersion = 2;

  late Box<Pet> _pets;
  late Box<HealthRecord> _records;

  Box<Pet> get petsBox => _pets;
  Box<HealthRecord> get recordsBox => _records;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PetAdapter());
    Hive.registerAdapter(HealthRecordAdapter());

    final prefs = await SharedPreferences.getInstance();
    final installed = prefs.getInt(_schemaKey) ?? 0;
    if (installed < _currentSchemaVersion) {
      try {
        await Hive.deleteBoxFromDisk(petsBoxName);
      } catch (_) {}
      try {
        await Hive.deleteBoxFromDisk(recordsBoxName);
      } catch (_) {}
      await prefs.setInt(_schemaKey, _currentSchemaVersion);
    }

    _pets = await Hive.openBox<Pet>(petsBoxName);
    _records = await Hive.openBox<HealthRecord>(recordsBoxName);
  }

  List<Pet> allPets() {
    final list = _pets.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<HealthRecord> recordsFor(String petId) {
    return _records.values
        .where((r) => r.petId == petId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> savePet(Pet pet) async {
    await _pets.put(pet.id, pet);
  }

  Future<void> deletePet(Pet pet) async {
    final recordIds = _records.values
        .where((r) => r.petId == pet.id)
        .map((r) => r.id)
        .toList();
    for (final id in recordIds) {
      await _records.delete(id);
    }
    await _pets.delete(pet.id);
  }

  Future<void> saveRecord(HealthRecord record) async {
    await _records.put(record.id, record);
  }

  Future<void> deleteRecord(HealthRecord record) async {
    await _records.delete(record.id);
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum Species {
  dog,
  cat,
  bird,
  rabbit,
  hamster,
  fish,
  reptile,
  other;

  String get icon => switch (this) {
        Species.dog => '🐕',
        Species.cat => '🐈',
        Species.bird => '🦜',
        Species.rabbit => '🐇',
        Species.hamster => '🐹',
        Species.fish => '🐟',
        Species.reptile => '🦎',
        Species.other => '🐾',
      };

  String label(AppLocalizations l) => switch (this) {
        Species.dog => l.speciesDog,
        Species.cat => l.speciesCat,
        Species.bird => l.speciesBird,
        Species.rabbit => l.speciesRabbit,
        Species.hamster => l.speciesHamster,
        Species.fish => l.speciesFish,
        Species.reptile => l.speciesReptile,
        Species.other => l.speciesOther,
      };

  String section(AppLocalizations l) => switch (this) {
        Species.dog => l.petsSectionDogs,
        Species.cat => l.petsSectionCats,
        Species.bird => l.petsSectionBirds,
        Species.rabbit => l.petsSectionRabbits,
        Species.hamster => l.petsSectionHamsters,
        Species.fish => l.petsSectionFish,
        Species.reptile => l.petsSectionReptiles,
        Species.other => l.petsSectionOther,
      };

  Color get accentColor => switch (this) {
        Species.dog => Colors.orange,
        Species.cat => Colors.purple,
        Species.bird => Colors.teal,
        Species.rabbit => Colors.pink,
        Species.hamster => Colors.brown,
        Species.fish => Colors.blue,
        Species.reptile => Colors.green,
        Species.other => Colors.grey,
      };
}

enum Gender {
  male,
  female;

  String label(AppLocalizations l) => switch (this) {
        Gender.male => l.genderMale,
        Gender.female => l.genderFemale,
      };

  IconData get icon => switch (this) {
        Gender.male => Icons.male,
        Gender.female => Icons.female,
      };
}

enum CoatType {
  short,
  medium,
  long,
  curly,
  hairless;

  String label(AppLocalizations l) => switch (this) {
        CoatType.short => l.coatShort,
        CoatType.medium => l.coatMedium,
        CoatType.long => l.coatLong,
        CoatType.curly => l.coatCurly,
        CoatType.hairless => l.coatHairless,
      };
}

enum PetStatus {
  alive,
  deceased,
  archived;

  String label(AppLocalizations l) => switch (this) {
        PetStatus.alive => l.statusAlive,
        PetStatus.deceased => l.statusDeceased,
        PetStatus.archived => l.statusArchived,
      };

  IconData get icon => switch (this) {
        PetStatus.alive => Icons.favorite,
        PetStatus.deceased => Icons.spa,
        PetStatus.archived => Icons.archive,
      };

  Color get color => switch (this) {
        PetStatus.alive => Colors.green,
        PetStatus.deceased => Colors.grey,
        PetStatus.archived => Colors.blueGrey,
      };
}

enum HealthRecordType {
  vaccine,
  deworming,
  consultation,
  surgery,
  exam,
  other;

  IconData get icon => switch (this) {
        HealthRecordType.vaccine => Icons.vaccines,
        HealthRecordType.deworming => Icons.healing,
        HealthRecordType.consultation => Icons.medical_services,
        HealthRecordType.surgery => Icons.local_hospital,
        HealthRecordType.exam => Icons.description,
        HealthRecordType.other => Icons.favorite,
      };

  Color get accentColor => switch (this) {
        HealthRecordType.vaccine => Colors.blue,
        HealthRecordType.deworming => Colors.green,
        HealthRecordType.consultation => Colors.orange,
        HealthRecordType.surgery => Colors.red,
        HealthRecordType.exam => Colors.purple,
        HealthRecordType.other => Colors.grey,
      };

  String label(AppLocalizations l) => switch (this) {
        HealthRecordType.vaccine => l.recordTypeVaccine,
        HealthRecordType.deworming => l.recordTypeDeworming,
        HealthRecordType.consultation => l.recordTypeConsultation,
        HealthRecordType.surgery => l.recordTypeSurgery,
        HealthRecordType.exam => l.recordTypeExam,
        HealthRecordType.other => l.recordTypeOther,
      };

  String placeholder(AppLocalizations l) => switch (this) {
        HealthRecordType.vaccine => l.recordFormPlaceholderVaccine,
        HealthRecordType.deworming => l.recordFormPlaceholderDeworming,
        HealthRecordType.consultation => l.recordFormPlaceholderConsultation,
        HealthRecordType.surgery => l.recordFormPlaceholderSurgery,
        HealthRecordType.exam => l.recordFormPlaceholderExam,
        HealthRecordType.other => l.recordFormPlaceholderOther,
      };
}

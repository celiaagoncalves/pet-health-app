import 'package:hive/hive.dart';

import 'enums.dart';

class HealthRecord extends HiveObject {
  String id;
  HealthRecordType type;
  String name;
  DateTime date;
  String notes;
  DateTime? nextDueDate;
  String petId;

  HealthRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.date,
    this.notes = '',
    this.nextDueDate,
    required this.petId,
  });

  String get notificationId => id;
  String get reminderNotificationId => '${id}_3d';
}

class HealthRecordAdapter extends TypeAdapter<HealthRecord> {
  @override
  final int typeId = 2;

  @override
  HealthRecord read(BinaryReader reader) {
    final id = reader.readString();
    final type = HealthRecordType.values[reader.readByte()];
    final name = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final notes = reader.readString();
    final hasNext = reader.readBool();
    final nextDueDate =
        hasNext ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final petId = reader.readString();
    return HealthRecord(
      id: id,
      type: type,
      name: name,
      date: date,
      notes: notes,
      nextDueDate: nextDueDate,
      petId: petId,
    );
  }

  @override
  void write(BinaryWriter writer, HealthRecord obj) {
    writer.writeString(obj.id);
    writer.writeByte(obj.type.index);
    writer.writeString(obj.name);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.notes);
    writer.writeBool(obj.nextDueDate != null);
    if (obj.nextDueDate != null) {
      writer.writeInt(obj.nextDueDate!.millisecondsSinceEpoch);
    }
    writer.writeString(obj.petId);
  }
}

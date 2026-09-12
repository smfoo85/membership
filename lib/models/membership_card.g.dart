// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MembershipCardAdapter extends TypeAdapter<MembershipCard> {
  @override
  final int typeId = 0;

  @override
  MembershipCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MembershipCard(
      id: fields[0] as String,
      storeName: fields[1] as String,
      codeValue: fields[2] as String,
      codeFormat: fields[3] as CodeFormat,
      logoPath: fields[4] as String?,
      colorValue: fields[5] as int,
      nickname: fields[6] as String?,
      dateAdded: fields[7] as DateTime,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MembershipCard obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.codeValue)
      ..writeByte(3)
      ..write(obj.codeFormat)
      ..writeByte(4)
      ..write(obj.logoPath)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.nickname)
      ..writeByte(7)
      ..write(obj.dateAdded)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MembershipCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

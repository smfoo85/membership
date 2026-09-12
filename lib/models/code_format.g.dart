// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_format.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CodeFormatAdapter extends TypeAdapter<CodeFormat> {
  @override
  final int typeId = 1;

  @override
  CodeFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CodeFormat.qr;
      case 1:
        return CodeFormat.code128;
      case 2:
        return CodeFormat.code39;
      case 3:
        return CodeFormat.ean13;
      case 4:
        return CodeFormat.upcA;
      case 5:
        return CodeFormat.pdf417;
      case 6:
        return CodeFormat.dataMatrix;
      case 7:
        return CodeFormat.aztec;
      default:
        return CodeFormat.qr;
    }
  }

  @override
  void write(BinaryWriter writer, CodeFormat obj) {
    switch (obj) {
      case CodeFormat.qr:
        writer.writeByte(0);
        break;
      case CodeFormat.code128:
        writer.writeByte(1);
        break;
      case CodeFormat.code39:
        writer.writeByte(2);
        break;
      case CodeFormat.ean13:
        writer.writeByte(3);
        break;
      case CodeFormat.upcA:
        writer.writeByte(4);
        break;
      case CodeFormat.pdf417:
        writer.writeByte(5);
        break;
      case CodeFormat.dataMatrix:
        writer.writeByte(6);
        break;
      case CodeFormat.aztec:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

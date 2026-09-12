import 'package:hive/hive.dart';

part 'code_format.g.dart';

@HiveType(typeId: 1)
enum CodeFormat {
  @HiveField(0)
  qr,
  @HiveField(1)
  code128,
  @HiveField(2)
  code39,
  @HiveField(3)
  ean13,
  @HiveField(4)
  upcA,
  @HiveField(5)
  pdf417,
  @HiveField(6)
  dataMatrix,
  @HiveField(7)
  aztec,
}

extension CodeFormatLabel on CodeFormat {
  String get label {
    switch (this) {
      case CodeFormat.qr:
        return 'QR Code';
      case CodeFormat.code128:
        return 'Code 128';
      case CodeFormat.code39:
        return 'Code 39';
      case CodeFormat.ean13:
        return 'EAN-13';
      case CodeFormat.upcA:
        return 'UPC-A';
      case CodeFormat.pdf417:
        return 'PDF417';
      case CodeFormat.dataMatrix:
        return 'Data Matrix';
      case CodeFormat.aztec:
        return 'Aztec';
    }
  }
}

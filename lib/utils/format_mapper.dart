import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/code_format.dart';

/// Maps a format detected by [MobileScanner] onto our persisted [CodeFormat].
CodeFormat mapScannerFormat(BarcodeFormat format) {
  switch (format) {
    case BarcodeFormat.qrCode:
      return CodeFormat.qr;
    case BarcodeFormat.code128:
      return CodeFormat.code128;
    case BarcodeFormat.code39:
      return CodeFormat.code39;
    case BarcodeFormat.ean13:
      return CodeFormat.ean13;
    case BarcodeFormat.upcA:
      return CodeFormat.upcA;
    case BarcodeFormat.pdf417:
      return CodeFormat.pdf417;
    case BarcodeFormat.dataMatrix:
      return CodeFormat.dataMatrix;
    case BarcodeFormat.aztec:
      return CodeFormat.aztec;
    default:
      // Safe fallback for unrecognized 1D formats (e.g. code93, codabar, itf).
      return CodeFormat.code128;
  }
}

/// Maps our persisted [CodeFormat] onto the `barcode_widget` renderer used
/// for every non-QR format.
bw.Barcode toBarcodeWidgetType(CodeFormat format) {
  switch (format) {
    case CodeFormat.qr:
      return bw.Barcode.qrCode();
    case CodeFormat.code128:
      return bw.Barcode.code128();
    case CodeFormat.code39:
      return bw.Barcode.code39();
    case CodeFormat.ean13:
      return bw.Barcode.ean13();
    case CodeFormat.upcA:
      return bw.Barcode.upcA();
    case CodeFormat.pdf417:
      return bw.Barcode.pdf417();
    case CodeFormat.dataMatrix:
      return bw.Barcode.dataMatrix();
    case CodeFormat.aztec:
      return bw.Barcode.aztec();
  }
}

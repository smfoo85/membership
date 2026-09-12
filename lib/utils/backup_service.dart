import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/membership_card.dart';

/// Exports/imports the wallet as a plain local JSON file. No network calls,
/// no server round-trip — this only ever touches the device's filesystem
/// and the OS share sheet.
class BackupService {
  Future<File> _writeExportFile(List<MembershipCard> cards) async {
    final payload = {
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'cards': cards.map((card) => card.toJson()).toList(),
    };
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/membership_wallet_backup.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }

  /// Writes the export file and opens the OS share sheet so the user can
  /// save it wherever they choose (Files app, another device, etc.).
  Future<void> exportAndShare(List<MembershipCard> cards) async {
    final file = await _writeExportFile(cards);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Membership Wallet backup',
    );
  }

  /// Lets the user pick a previously exported JSON file and parses it into
  /// a list of cards. Returns null if the user cancelled the picker.
  Future<List<MembershipCard>?> pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = result.files.single;
    final bytes = picked.bytes ?? (picked.path != null ? await File(picked.path!).readAsBytes() : null);
    if (bytes == null) {
      throw const FormatException('Could not read the selected file.');
    }

    final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final rawCards = decoded['cards'] as List<dynamic>? ?? [];
    return rawCards
        .cast<Map<String, dynamic>>()
        .map(MembershipCard.fromJson)
        .toList();
  }
}

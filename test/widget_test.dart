import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:membership_wallet/data/card_repository.dart';
import 'package:membership_wallet/data/settings_repository.dart';
import 'package:membership_wallet/main.dart';
import 'package:membership_wallet/models/code_format.dart';
import 'package:membership_wallet/models/membership_card.dart';

// Real (non-fake) async I/O — opening Hive boxes, writing cards — must happen
// in setUp, never inside a testWidgets body: the automated test binding only
// flushes such pending futures on a pump(), so awaiting them directly inside
// a test callback (before any pump) hangs forever.
Future<Directory> _openFreshHive() async {
  final tempDir = await Directory.systemTemp.createTemp('membership_wallet_test');
  Hive.init(tempDir.path);
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MembershipCardAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CodeFormatAdapter());
  await CardRepository.openBox();
  await SettingsRepository.openBox();
  return tempDir;
}

void main() {
  group('empty wallet', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await _openFreshHive();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    testWidgets('shows the empty wallet state on first launch', (WidgetTester tester) async {
      await tester.pumpWidget(const MembershipWalletApp());
      await tester.pump();

      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.textContaining('No membership cards yet'), findsOneWidget);
    });
  });

  group('wallet with a saved card', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await _openFreshHive();
      await CardRepository().add(
        MembershipCard(
          id: 'test-1',
          storeName: 'Test Grocer',
          codeValue: '1234567890',
          codeFormat: CodeFormat.code128,
          colorValue: 0xFF1976D2,
          dateAdded: DateTime(2026, 1, 1),
        ),
      );
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    testWidgets('a saved card appears in the wallet list', (WidgetTester tester) async {
      await tester.pumpWidget(const MembershipWalletApp());
      await tester.pump();

      expect(find.text('Test Grocer'), findsOneWidget);
    });
  });
}

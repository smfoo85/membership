import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/card_repository.dart';
import 'data/settings_repository.dart';
import 'models/code_format.dart';
import 'models/membership_card.dart';
import 'screens/app_lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MembershipCardAdapter());
  Hive.registerAdapter(CodeFormatAdapter());
  await CardRepository.openBox();
  await SettingsRepository.openBox();

  runApp(const MembershipWalletApp());
}

class MembershipWalletApp extends StatelessWidget {
  const MembershipWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Membership Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AppLockGate(repository: CardRepository()),
    );
  }
}

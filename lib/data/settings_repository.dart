import 'package:hive_flutter/hive_flutter.dart';

/// Small key-value store for app settings (currently just the biometric
/// lock toggle). Backed by its own Hive box, kept separate from the card
/// data box.
class SettingsRepository {
  static const String boxName = 'settings';
  static const String _biometricLockKey = 'biometricLockEnabled';

  Box get _box => Hive.box(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  bool get biometricLockEnabled => _box.get(_biometricLockKey, defaultValue: false) as bool;

  Future<void> setBiometricLockEnabled(bool enabled) => _box.put(_biometricLockKey, enabled);
}

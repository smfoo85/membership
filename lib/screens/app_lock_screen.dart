import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../data/card_repository.dart';
import '../data/settings_repository.dart';
import 'wallet_home_screen.dart';

/// Gates access to the wallet behind an OS-level biometric/PIN prompt when
/// the user has turned the app lock on in Settings. Locks again whenever
/// the app returns to the foreground.
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.repository});

  final CardRepository repository;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  final _settings = SettingsRepository();
  final _localAuth = LocalAuthentication();

  late bool _unlocked = !_settings.biometricLockEnabled;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_unlocked) _attemptUnlock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _settings.biometricLockEnabled) {
      setState(() => _unlocked = false);
    }
  }

  Future<void> _attemptUnlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      final authenticated = canAuthenticate &&
          await _localAuth.authenticate(localizedReason: 'Unlock your membership wallet');
      if (authenticated && mounted) {
        setState(() => _unlocked = true);
      }
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) {
      return WalletHomeScreen(repository: widget.repository);
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Membership Wallet is locked', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _authenticating ? null : _attemptUnlock,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

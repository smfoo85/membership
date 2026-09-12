import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../data/card_repository.dart';
import '../data/settings_repository.dart';
import '../utils/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.repository});

  final CardRepository repository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsRepository();
  final _backupService = BackupService();
  final _localAuth = LocalAuthentication();
  bool _busy = false;

  Future<void> _onBiometricToggle(bool enable) async {
    if (enable) {
      final canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No biometric/PIN lock is set up on this device.')),
          );
        }
        return;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirm to enable the app lock',
      );
      if (!authenticated) return;
    }
    await _settings.setBiometricLockEnabled(enable);
    setState(() {});
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await _backupService.exportAndShare(widget.repository.getAll());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    try {
      final cards = await _backupService.pickAndImport();
      if (cards == null) return;
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace all cards?'),
          content: Text(
            'This will replace your current wallet with the ${cards.length} card(s) from the backup file. '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Replace')),
          ],
        ),
      );
      if (confirmed == true) {
        await widget.repository.replaceAll(cards);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported ${cards.length} card(s).')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Opacity(
          opacity: _busy ? 0.5 : 1,
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('App lock'),
                subtitle: const Text('Require fingerprint / face / PIN to open the app'),
                value: _settings.biometricLockEnabled,
                onChanged: _onBiometricToggle,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.upload_outlined),
                title: const Text('Export backup'),
                subtitle: const Text('Save all cards to a local JSON file'),
                onTap: _export,
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Import backup'),
                subtitle: const Text('Replace your wallet from a backup file'),
                onTap: _import,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Wallet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'This app stores your membership card barcodes and QR codes entirely on your device. '
              'Nothing is uploaded, transmitted, or shared with any server — there is no account, '
              'no backend, and no network access.',
            ),
            SizedBox(height: 16),
            Text(
              'This app is an independent tool for storing your own membership card codes and is not '
              'affiliated with, endorsed by, or sponsored by any retailer.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

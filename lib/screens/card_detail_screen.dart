import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/card_repository.dart';
import '../models/code_format.dart';
import '../models/membership_card.dart';
import '../theme/app_theme.dart';
import '../widgets/code_renderer.dart';
import '../widgets/logo_avatar.dart';
import 'add_card_screen.dart';

/// Full-screen code display. Keeps the screen awake and boosts brightness
/// for the duration so the code stays legible and visible at checkout,
/// restoring both when the screen is left.
class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.repository, required this.card});

  final CardRepository repository;
  final MembershipCard card;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  @override
  void initState() {
    super.initState();
    _boostForCheckout();
  }

  Future<void> _boostForCheckout() async {
    await WakelockPlus.enable();
    try {
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (_) {
      // Brightness control isn't available on every platform (e.g. desktop) —
      // the wakelock alone is still useful, so don't block on this.
    }
  }

  Future<void> _restore() async {
    await WakelockPlus.disable();
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (_) {}
  }

  @override
  void dispose() {
    _restore();
    super.dispose();
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('This will permanently remove "${widget.card.displayName}".'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.delete(widget.card);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Scaffold(
      appBar: AppBar(
        title: Text(card.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddCardScreen(repository: widget.repository, existingCard: card),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LogoAvatar(card: card, radius: 32),
                const SizedBox(height: 16),
                Text(card.displayName, style: Theme.of(context).textTheme.headlineSmall),
                if (card.nickname != null) Text(card.storeName, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                // "Code Display Pod" — deliberately breaks the dark theme
                // with a solid white plate for maximum scanner contrast.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.codePodBackground,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CodeRenderer(card: card, size: 260),
                      const SizedBox(height: 12),
                      SelectableText(
                        card.codeValue,
                        style: AppTheme.codeDisplay.copyWith(color: AppColors.codePodForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(card.codeFormat.label, style: Theme.of(context).textTheme.bodySmall),
                if (card.notes != null && card.notes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Notes', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  const SizedBox(height: 4),
                  Text(card.notes!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

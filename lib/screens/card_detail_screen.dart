import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/// restoring both when the screen is left (or the user turns the toggle off).
class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.repository, required this.card});

  final CardRepository repository;
  final MembershipCard card;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  bool _maxBrightness = true;
  late CodeFormat _displayFormat = widget.card.codeFormat;

  /// Whether an alternate display format makes sense for this card's value —
  /// only offer the toggle for the two formats we can meaningfully render
  /// (a 1D symbology's value re-encoded as a QR looks/scans fine; other
  /// combinations aren't worth confusing the user with).
  bool get _showFormatToggle => widget.card.codeFormat != CodeFormat.qr;

  @override
  void initState() {
    super.initState();
    _applyBrightness();
  }

  Future<void> _applyBrightness() async {
    if (_maxBrightness) {
      await WakelockPlus.enable();
      try {
        await ScreenBrightness().setScreenBrightness(1.0);
      } catch (_) {
        // Brightness control isn't available on every platform (e.g. desktop) —
        // the wakelock alone is still useful, so don't block on this.
      }
    } else {
      await WakelockPlus.disable();
      try {
        await ScreenBrightness().resetScreenBrightness();
      } catch (_) {}
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

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: widget.card.codeValue));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card number copied'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final baseColor = Color(card.colorValue);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top auxiliary action row.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PillButton(
                    label: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddCardScreen(repository: widget.repository, existingCard: card),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CircleIconButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Delete',
                        onPressed: () => _delete(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini pass card banner, echoing the wallet tile's gradient.
              AspectRatio(
                aspectRatio: 1.586,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [baseColor, Color.lerp(baseColor, Colors.black, 0.55)!],
                    ),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LogoAvatar(card: card, radius: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.displayName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (card.nickname != null && card.nickname!.trim().isNotEmpty)
                                  Text(
                                    card.storeName,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ADDED',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1),
                                ),
                                Text(
                                  _formatDate(card.dateAdded),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            card.codeFormat.label,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Dedicated scan zone pod.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Brightness status row (real, functional toggle).
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.brightness_high, size: 18, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Max POS Brightness', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          ),
                          Text(
                            _maxBrightness ? 'Active' : 'Standard',
                            style: TextStyle(
                              color: _maxBrightness ? AppColors.secondary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: _maxBrightness,
                            onChanged: (value) {
                              setState(() => _maxBrightness = value);
                              _applyBrightness();
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_showFormatToggle) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SegmentButton(
                                label: card.codeFormat.label,
                                icon: Icons.barcode_reader,
                                selected: _displayFormat != CodeFormat.qr,
                                onTap: () => setState(() => _displayFormat = card.codeFormat),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _SegmentButton(
                                label: 'QR Code',
                                icon: Icons.qr_code_2,
                                selected: _displayFormat == CodeFormat.qr,
                                onTap: () => setState(() => _displayFormat = CodeFormat.qr),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // "Code Display Pod" — deliberately breaks the dark theme
                    // with a solid white plate for maximum scanner contrast.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.codePodBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: CodeRenderer(card: card, size: 220, formatOverride: _displayFormat),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _copyCode,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Card Number',
                                      style: Theme.of(context).textTheme.labelMedium,
                                    ),
                                    Text(
                                      card.codeValue,
                                      style: AppTheme.codeDisplay.copyWith(fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.content_copy, size: 18, color: AppColors.primary),
                              const SizedBox(width: 4),
                              const Text('Copy', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (card.notes != null && card.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(card.notes!, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surfaceHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

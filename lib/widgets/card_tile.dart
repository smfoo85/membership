import 'package:flutter/material.dart';

import '../models/code_format.dart';
import '../models/membership_card.dart';
import '../theme/app_theme.dart';
import 'logo_avatar.dart';

/// A "wallet pass card" row on the home screen — a gradient card in the
/// card's chosen color, echoing the physical-pass look of the PassPocket
/// design system, with a mini code pod so the card is recognizable at a
/// glance without opening it.
class CardTile extends StatelessWidget {
  const CardTile({super.key, required this.card, required this.onTap});

  final MembershipCard card;
  final VoidCallback onTap;

  String get _maskedCode {
    final digits = card.codeValue.replaceAll(RegExp(r'\s'), '');
    if (digits.length <= 4) return card.codeValue;
    return '•••• ${digits.substring(digits.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(card.colorValue);
    final hasNickname = card.nickname != null && card.nickname!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseColor, Color.lerp(baseColor, Colors.black, 0.55)!],
              ),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LogoAvatar(card: card, radius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasNickname)
                            Text(
                              card.storeName.toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          Text(
                            card.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.85)),
                  ],
                ),
                const SizedBox(height: 12),
                // "Bottom Pod" — a translucent strip previewing the code,
                // mirroring the design system's substrate-on-card pattern.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Icon(
                          card.codeFormat == CodeFormat.qr ? Icons.qr_code_2 : Icons.barcode_reader,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _maskedCode,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.codeDisplay.copyWith(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Ready',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

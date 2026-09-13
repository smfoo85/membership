import 'package:flutter/material.dart';

import '../models/code_format.dart';
import '../models/membership_card.dart';
import 'logo_avatar.dart';

/// A "wallet pass card" row on the home screen — a gradient card in the
/// card's chosen color, echoing the physical-pass look of the PassPocket
/// design system rather than a plain list row.
class CardTile extends StatelessWidget {
  const CardTile({super.key, required this.card, required this.onTap});

  final MembershipCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseColor = Color(card.colorValue);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            height: 96,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseColor, Color.lerp(baseColor, Colors.black, 0.45)!],
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
            child: Row(
              children: [
                LogoAvatar(card: card, radius: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.codeFormat.label,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.85)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

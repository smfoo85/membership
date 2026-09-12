import 'dart:io';

import 'package:flutter/material.dart';

import '../models/membership_card.dart';

/// Shows the card's uploaded logo, or falls back to a colored circle with
/// the store name's initial when no logo has been set.
class LogoAvatar extends StatelessWidget {
  const LogoAvatar({super.key, required this.card, this.radius = 24});

  final MembershipCard card;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final logoPath = card.logoPath;
    if (logoPath != null && File(logoPath).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(logoPath)),
      );
    }

    final trimmedName = card.displayName.trim();
    final initial = trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(card.colorValue),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}

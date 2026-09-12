import 'package:flutter/material.dart';

import '../models/code_format.dart';
import '../models/membership_card.dart';
import 'logo_avatar.dart';

/// A single row in the wallet home list.
class CardTile extends StatelessWidget {
  const CardTile({super.key, required this.card, required this.onTap});

  final MembershipCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: LogoAvatar(card: card),
      title: Text(card.displayName),
      subtitle: Text(card.codeFormat.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

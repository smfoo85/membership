import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/card_repository.dart';
import '../models/membership_card.dart';
import '../theme/app_theme.dart';
import '../widgets/card_tile.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'settings_screen.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key, required this.repository});

  final CardRepository repository;

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  String _query = '';

  List<MembershipCard> _filtered(List<MembershipCard> cards) {
    if (_query.trim().isEmpty) return cards;
    final query = _query.trim().toLowerCase();
    return cards.where((card) => card.displayName.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Wallet', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<Box<MembershipCard>>(
                          valueListenable: widget.repository.listenable(),
                          builder: (context, box, _) {
                            final count = widget.repository.getAll().length;
                            return Row(
                              children: [
                                _StatusChip(
                                  icon: Icons.circle,
                                  iconSize: 8,
                                  iconColor: AppColors.secondary,
                                  label: '$count ${count == 1 ? 'Card' : 'Cards'}',
                                  textColor: AppColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                const _StatusChip(
                                  icon: Icons.brightness_auto,
                                  iconSize: 13,
                                  iconColor: AppColors.tertiary,
                                  label: 'Max Auto',
                                  textColor: AppColors.onSurfaceVariant,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(repository: widget.repository),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 28),
                    color: AppColors.primary,
                    tooltip: 'Scan New Card',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddCardScreen(repository: widget.repository),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search memberships, stores, brands...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<MembershipCard>>(
                valueListenable: widget.repository.listenable(),
                builder: (context, box, _) {
                  final cards = _filtered(widget.repository.getAll());
                  if (cards.isEmpty) {
                    return _EmptyState(hasQuery: _query.trim().isNotEmpty);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return CardTile(
                        card: card,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CardDetailScreen(
                              repository: widget.repository,
                              card: card,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small rounded status pill, e.g. "3 Cards" or "Max Auto" brightness.
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.textColor,
    this.iconSize = 12,
  });

  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wallet_outlined, size: 64, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No cards match your search.' : 'No membership cards yet.\nTap + to scan or add one.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

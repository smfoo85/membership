import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/card_repository.dart';
import '../models/membership_card.dart';
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
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(repository: widget.repository),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search cards',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                return ListView.separated(
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddCardScreen(repository: widget.repository),
          ),
        ),
        child: const Icon(Icons.add),
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

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/membership_card.dart';

/// Wraps the single `membership_cards` Hive box with the CRUD surface the
/// rest of the app needs. All data stays on-device — this never touches
/// the network.
class CardRepository {
  static const String boxName = 'membership_cards';

  Box<MembershipCard> get _box => Hive.box<MembershipCard>(boxName);

  static Future<void> openBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<MembershipCard>(boxName);
    }
  }

  List<MembershipCard> getAll() {
    final cards = _box.values.toList();
    cards.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    return cards;
  }

  ValueListenable<Box<MembershipCard>> listenable() => _box.listenable();

  MembershipCard? getById(String id) {
    try {
      return _box.values.firstWhere((card) => card.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(MembershipCard card) async {
    await _box.put(card.id, card);
  }

  Future<void> update(MembershipCard card) async {
    await card.save();
  }

  Future<void> delete(MembershipCard card) async {
    await card.delete();
  }

  Future<void> replaceAll(List<MembershipCard> cards) async {
    await _box.clear();
    for (final card in cards) {
      await _box.put(card.id, card);
    }
  }
}

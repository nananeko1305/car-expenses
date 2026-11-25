import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/wallet_entry.dart';
import '../services/euro_visibility.dart';
import '../services/live_data.dart';
import '../widgets/balance_card.dart';
import '../widgets/wallet_history.dart';
import 'repair_form_screen.dart';
import 'wallet_entry_screen.dart';

/// Shared wallet: balance, add/spend actions and the history, one month
/// at a time. The balance always covers every month. Euros show only
/// while [euroVisibility] is on.
/// Services marked "add to wallet" count as income automatically.
class WalletTab extends StatelessWidget {
  const WalletTab({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openEntry(
    BuildContext context,
    WalletEntryType type, [
    WalletEntry? entry,
  ]) {
    _push(
      context,
      WalletEntryScreen(data: data, profile: profile, type: type, entry: entry),
    );
  }

  void _openMovement(BuildContext context, WalletMovement m) {
    if (m.repair != null) {
      _push(
        context,
        RepairFormScreen(data: data, profile: profile, repair: m.repair),
      );
    } else {
      _openEntry(context, m.entry!.type, m.entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movements = WalletMovement.merge(data.repairs!, data.entries!);

    return ListenableBuilder(
      listenable: euroVisibility,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          BalanceCard(
            balances: WalletMovement.balances(movements),
            showEuros: euroVisibility.shown,
            onShowEuros: euroVisibility.set,
            onAdd: () => _openEntry(context, WalletEntryType.deposit),
            onSpend: () => _openEntry(context, WalletEntryType.withdrawal),
          ),
          const SizedBox(height: 8),
          WalletHistory(
            movements: movements,
            showEuros: euroVisibility.shown,
            nameOf: data.nameOf,
            onTap: (m) => _openMovement(context, m),
          ),
        ],
      ),
    );
  }
}

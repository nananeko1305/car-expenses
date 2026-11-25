import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/wallet_entry.dart';
import '../services/euro_visibility.dart';
import '../services/live_data.dart';
import '../widgets/balance_card.dart';
import '../widgets/slant_header.dart';
import '../widgets/wallet_history.dart';
import 'repair_form_screen.dart';
import 'wallet_entry_screen.dart';

/// Shared wallet: balance and add/spend actions in the header block, and
/// under it the history, one month at a time. The balance always covers
/// every month. Euros show only while [euroVisibility] is on.
/// Services marked "add to wallet" count as income automatically.
class WalletTab extends StatelessWidget {
  const WalletTab({
    super.key,
    required this.data,
    required this.profile,
    required this.onSearch,
  });

  final LiveData data;
  final AppUser profile;

  /// Opens the search by plate, from the header.
  final VoidCallback onSearch;

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

    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: euroVisibility,
      builder: (context, _) => Column(
        children: [
          SlantHeader(
            title: t.wallet,
            actions: [
              IconButton(
                tooltip: t.searchPlate,
                icon: const Icon(Icons.search_rounded),
                onPressed: onSearch,
              ),
            ],
            child: BalanceCard(
              balances: WalletMovement.balances(movements),
              showEuros: euroVisibility.shown,
              onShowEuros: euroVisibility.set,
              onAdd: () => _openEntry(context, WalletEntryType.deposit),
              onSpend: () => _openEntry(context, WalletEntryType.withdrawal),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                WalletHistory(
                  movements: movements,
                  showEuros: euroVisibility.shown,
                  nameOf: data.nameOf,
                  onTap: (m) => _openMovement(context, m),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

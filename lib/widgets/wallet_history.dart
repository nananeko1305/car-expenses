import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../models/wallet_entry.dart';
import '../theme/app_colors.dart';
import 'month_switcher.dart';
import 'movement_tile.dart';
import 'wallet_month_summary.dart';

/// The wallet's history one month at a time, starting at the current
/// one: a switcher, what that month came to, and its movements. The
/// months run from the oldest movement to now.
class WalletHistory extends StatefulWidget {
  const WalletHistory({
    super.key,
    required this.movements,
    required this.showEuros,
    required this.nameOf,
    required this.onTap,
  });

  /// Every movement there is, newest first.
  final List<WalletMovement> movements;

  /// Whether the month's sums list euros as well.
  final bool showEuros;
  final String Function(String uid) nameOf;
  final ValueChanged<WalletMovement> onTap;

  @override
  State<WalletHistory> createState() => _WalletHistoryState();
}

class _WalletHistoryState extends State<WalletHistory> {
  DateTime _month = monthOf(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final all = widget.movements;
    // An empty wallet has no months to step through.
    if (all.isEmpty) return _note(t.noMovements);

    final span = monthSpan(all.map((m) => m.date), DateTime.now());
    final shown = all.where((m) => inMonth(m.date, _month)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: MonthSwitcher(
            month: _month,
            first: span.first,
            last: span.last,
            onChanged: (m) => setState(() => _month = m),
          ),
        ),
        if (shown.isEmpty)
          _note(t.noMovementsInMonth)
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: WalletMonthSummary(
              movements: shown,
              showEuros: widget.showEuros,
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: context.colors.line),
        ],
        for (final m in shown)
          MovementTile(
            movement: m,
            personName: widget.nameOf(m.userId),
            onTap: () => widget.onTap(m),
          ),
      ],
    );
  }

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Text(text, textAlign: TextAlign.center),
  );
}

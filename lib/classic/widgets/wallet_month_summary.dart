import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/repair.dart';
import '../../models/wallet_entry.dart';
import '../../money/money.dart';
import 'money_row.dart';

/// What one month did to the wallet: what came in, what was spent, and
/// what is left of the two. Laid out like the bottom of the monthly
/// report, but it counts only money that passed through the wallet.
class WalletMonthSummary extends StatelessWidget {
  const WalletMonthSummary({
    super.key,
    required this.movements,
    required this.showEuros,
  });

  /// The movements of that month.
  final List<WalletMovement> movements;
  final bool showEuros;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final flows = WalletMovement.flows(movements);
    Map<Currency, int> lines(Map<Currency, int> sums) =>
        walletLines(sums, showEuros: showEuros);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Column(
          children: [
            MoneyRow(label: t.walletIn, sums: lines(flows.moneyIn)),
            MoneyRow(
              label: t.walletSpent,
              sums: lines(flows.moneyOut),
              sign: '− ',
            ),
            const Divider(height: 16),
            MoneyRow(
              label: t.walletEarned,
              sums: lines(WalletMovement.balances(movements)),
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

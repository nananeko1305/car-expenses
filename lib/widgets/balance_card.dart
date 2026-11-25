import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'repair_card.dart';
import 'skewed.dart';

/// Wallet balance per currency, with "add funds" and "spend" actions.
/// Euros are rare, so their line shows only while the switch in the
/// corner is on.
///
/// Drawn for the accent block at the top of the wallet tab: its text and
/// buttons take that block's text color.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balances,
    required this.showEuros,
    required this.onShowEuros,
    required this.onAdd,
    required this.onSpend,
  });

  final Map<Currency, int> balances;
  final bool showEuros;
  final ValueChanged<bool> onShowEuros;
  final VoidCallback onAdd;
  final VoidCallback onSpend;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shown = walletLines(balances, showEuros: showEuros);
    final label = TextStyle(
      color: c.onPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(t.balance, style: label)),
            MergeSemantics(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onShowEuros(!showEuros),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(t.showEuros, style: label),
                    ),
                    SkewSwitch(
                      value: showEuros,
                      onChanged: onShowEuros,
                      onAccent: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        for (final currency in Currency.values)
          if (shown.containsKey(currency))
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: MoneyText(
                formatMoney(shown[currency]!, currency, locale),
                size: 36,
                // Below zero it stands out: amber on a dark accent, and
                // the "money out" red on a light one.
                color: shown[currency]! >= 0
                    ? c.onPrimary
                    : ThemeData.estimateBrightnessForColor(c.onPrimary) ==
                          Brightness.light
                    ? const Color(0xFFFFD166)
                    : c.moneyOut,
              ),
            ),
        const SizedBox(height: 12),
        Padding(
          // The buttons lean, so they need room at both ends.
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Expanded(
                child: SkewButton(
                  label: t.addFunds,
                  icon: Icons.add_rounded,
                  background: c.onPrimary,
                  foreground: c.primary,
                  onPressed: onAdd,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkewButton(
                  label: t.spendFunds,
                  icon: Icons.remove_rounded,
                  outlined: true,
                  foreground: c.onPrimary,
                  onPressed: onSpend,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../models/wallet_entry.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'skewed.dart';

/// What one month did to the wallet, as three leaning tiles side by
/// side: what came in, what was spent, and what is left of the two. It
/// counts only money that passed through the wallet.
///
/// Dinars are the bare number; euros, shown only when [showEuros] asks
/// for them, carry their sign.
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
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final flows = WalletMovement.flows(movements);
    final net = walletLines(
      WalletMovement.balances(movements),
      showEuros: showEuros,
    );
    final inTheRed = net.values.any((minor) => minor < 0);

    List<String> lines(Map<Currency, int> sums, {bool spent = false}) => [
      for (final MapEntry(key: currency, value: minor) in walletLines(
        sums,
        showEuros: showEuros,
      ).entries)
        _figure(spent ? -minor : minor, currency, locale),
    ];

    return Padding(
      // The tiles lean, so they need room at both ends.
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Tile(
                label: t.walletIn,
                lines: lines(flows.moneyIn),
                background: c.panel,
                foreground: c.ink,
                labelColor: c.muted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(
                label: t.walletSpent,
                lines: lines(flows.moneyOut, spent: true),
                background: c.panel,
                foreground: c.ink,
                labelColor: c.muted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(
                label: t.walletEarned,
                lines: lines(WalletMovement.balances(movements)),
                // The bottom line is the dark block; a month in the red
                // says so with its color.
                background: inTheRed ? c.moneyOut : c.ink,
                foreground: c.background,
                labelColor: c.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "12.000,00" for dinars and "50,00 €" for euros, with a real minus
  /// sign and none before a zero.
  static String _figure(int minor, Currency currency, String locale) {
    final number = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(minor.abs() / 100);
    final sign = minor < 0 ? '−' : '';
    return currency == Currency.eur ? '$sign$number €' : '$sign$number';
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.label,
    required this.lines,
    required this.background,
    required this.foreground,
    required this.labelColor,
  });

  final String label;
  final List<String> lines;
  final Color background;
  final Color foreground;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Skewed(
      angle: Skewed.eightDegrees,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            for (final line in lines)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  line,
                  maxLines: 1,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

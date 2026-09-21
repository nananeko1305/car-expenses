import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';
import '../theme/app_theme.dart';

/// Wallet balance per currency, with "add funds" and "spend" actions.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balances,
    required this.onAdd,
    required this.onSpend,
  });

  final Map<Currency, int> balances;
  final VoidCallback onAdd;
  final VoidCallback onSpend;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shown = balances.isEmpty ? {Currency.rsd: 0} : balances;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.terracotta,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.balance,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          for (final c in Currency.values)
            if (shown.containsKey(c))
              Text(
                formatMoney(shown[c]!, c, locale),
                style: TextStyle(
                  // A negative balance stands out in amber.
                  color: shown[c]! < 0 ? const Color(0xFFFFD166) : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _button(Icons.add_rounded, t.addFunds, onAdd)),
              const SizedBox(width: 10),
              Expanded(
                child: _button(Icons.remove_rounded, t.spendFunds, onSpend),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(IconData icon, String label, VoidCallback onPressed) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.terracotta,
        minimumSize: const Size.fromHeight(46),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

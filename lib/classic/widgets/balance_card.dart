import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/repair.dart';
import '../../money/money.dart';
import '../theme/app_colors.dart';

/// Wallet balance per currency, with "add funds" and "spend" actions.
/// Euros are rare, so their line shows only while the switch in the
/// corner is on.
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shown = walletLines(balances, showEuros: showEuros);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.balance,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _EuroSwitch(value: showEuros, onChanged: onShowEuros),
            ],
          ),
          const SizedBox(height: 2),
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
              Expanded(
                child: _button(context, Icons.add_rounded, t.addFunds, onAdd),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _button(
                  context,
                  Icons.remove_rounded,
                  t.spendFunds,
                  onSpend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: context.colors.primary,
        minimumSize: const Size.fromHeight(46),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

/// "Euros" with its switch, in the card's white-on-accent look. The label
/// flips it too, since the switch alone is a small target.
class _EuroSwitch extends StatelessWidget {
  const _EuroSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 0, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).showEuros,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.white.withValues(
                    alpha: states.contains(WidgetState.selected) ? 0.45 : 0.12,
                  ),
                ),
                trackOutlineColor: WidgetStatePropertyAll(
                  Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

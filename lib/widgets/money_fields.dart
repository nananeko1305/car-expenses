import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';
import '../theme/app_colors.dart';
import 'skewed.dart';

/// Amount input with the RSD / EUR choice next to it, on one line.
///
/// With [optional] the amount may be left blank — used for a tool that
/// has no wallet entry to take its price from.
class MoneyFields extends StatelessWidget {
  const MoneyFields({
    super.key,
    required this.amount,
    required this.currency,
    required this.onCurrency,
    this.enabled = true,
    this.optional = false,
    this.helperText,
  });

  final TextEditingController amount;
  final Currency currency;
  final ValueChanged<Currency> onCurrency;
  final bool enabled;
  final bool optional;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: amount,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              labelText: t.amount,
              helperText: helperText,
              helperMaxLines: 2,
            ),
            validator: (v) {
              if (optional && (v == null || v.trim().isEmpty)) return null;
              return parseMoney(v ?? '') == null ? t.invalidAmount : null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, option) in Currency.values.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                _CurrencyButton(
                  label: option.code,
                  selected: option == currency,
                  onTap: enabled ? () => onCurrency(option) : null,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One of the two currencies as a leaning box, dark when it is the one.
class _CurrencyButton extends StatelessWidget {
  const _CurrencyButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Skewed(
        child: Material(
          color: selected ? c.ink : c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: c.ink, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 54,
              height: 44,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? c.background : c.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';

/// Amount input plus the RSD / EUR switch.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: amount,
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: t.amount,
            helperText: helperText,
            prefixIcon: const Icon(Icons.payments_rounded),
          ),
          validator: (v) {
            if (optional && (v == null || v.trim().isEmpty)) return null;
            return parseMoney(v ?? '') == null ? t.invalidAmount : null;
          },
        ),
        const SizedBox(height: 10),
        SegmentedButton<Currency>(
          segments: const [
            ButtonSegment(value: Currency.rsd, label: Text('RSD')),
            ButtonSegment(value: Currency.eur, label: Text('EUR €')),
          ],
          selected: {currency},
          onSelectionChanged: enabled ? (s) => onCurrency(s.first) : null,
        ),
      ],
    );
  }
}

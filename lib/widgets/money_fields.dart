import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';

/// Amount input plus the RSD / EUR switch.
class MoneyFields extends StatelessWidget {
  const MoneyFields({
    super.key,
    required this.amount,
    required this.currency,
    required this.onCurrency,
    this.enabled = true,
  });

  final TextEditingController amount;
  final Currency currency;
  final ValueChanged<Currency> onCurrency;
  final bool enabled;

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
            prefixIcon: const Icon(Icons.payments_rounded),
          ),
          validator: (v) =>
              parseMoney(v ?? '') == null ? t.invalidAmount : null,
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

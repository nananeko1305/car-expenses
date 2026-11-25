import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import 'money_fields.dart';

/// What a service cost: a "no charge" switch and, while it is off, the
/// amount with its currency. No charge is for work nobody pays for, such
/// as the mechanic's own car, so it asks for no amount at all.
class RepairPriceFields extends StatelessWidget {
  const RepairPriceFields({
    super.key,
    required this.free,
    required this.onFree,
    required this.amount,
    required this.currency,
    required this.onCurrency,
    this.enabled = true,
  });

  final bool free;
  final ValueChanged<bool> onFree;
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.money_off_rounded),
          title: Text(t.noCharge),
          subtitle: Text(t.noChargeHint),
          value: free,
          onChanged: enabled ? onFree : null,
        ),
        if (!free) ...[
          const SizedBox(height: 6),
          MoneyFields(
            amount: amount,
            currency: currency,
            enabled: enabled,
            onCurrency: onCurrency,
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/repair.dart';
import '../money/money.dart';

/// "Not enough money in the wallet": what is [available] in [currency]
/// and what the spending asked for. Closing it leaves the form open, so
/// the amount can be changed.
Future<void> showShortfallDialog(
  BuildContext context, {
  required int available,
  required int amount,
  required Currency currency,
}) {
  final t = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.account_balance_wallet_outlined, size: 36),
      title: Text(t.notEnoughMoney),
      content: Text(
        t.notEnoughMoneyBody(
          formatMoney(available, currency, locale),
          formatMoney(amount, currency, locale),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t.close),
        ),
      ],
    ),
  );
}

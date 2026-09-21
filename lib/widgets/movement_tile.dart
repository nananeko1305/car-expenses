import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/wallet_entry.dart';
import '../money/money.dart';
import '../theme/app_theme.dart';

/// One wallet history line: kind, description, date, person, +/- amount.
class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    required this.personName,
    required this.onTap,
  });

  final WalletMovement movement;
  final String personName;
  final VoidCallback onTap;

  static const _green = Color(0xFF22A06B);
  static const _red = Color(0xFFD94E4E);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final m = movement;
    final incoming = m.signedMinor >= 0;
    final (IconData icon, String kind) = switch (m) {
      _ when m.repair != null => (Icons.car_repair_rounded, t.serviceIncome),
      _ when incoming => (Icons.south_west_rounded, t.deposit),
      _ => (Icons.north_east_rounded, t.withdrawal),
    };
    final color = incoming ? _green : _red;
    final amount = formatMoney(m.signedMinor.abs(), m.currency, locale);
    final date = DateFormat.yMMMd(locale).format(m.date);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: color,
          child: Icon(icon, size: 20),
        ),
        title: Text(
          m.description.isEmpty ? kind : m.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '$kind · $date · $personName',
          style: TextStyle(color: AppTheme.ink.withValues(alpha: 0.65)),
        ),
        trailing: Text(
          '${incoming ? '+' : '−'} $amount',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

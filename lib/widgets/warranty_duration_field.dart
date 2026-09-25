import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/warranty.dart';

/// How long the warranty lasts: a number plus months or years.
///
/// The helper text shows the date the warranty runs out, which is the
/// best defence against a number typed in the wrong unit.
class WarrantyDurationField extends StatefulWidget {
  const WarrantyDurationField({
    super.key,
    required this.amount,
    required this.unit,
    required this.onUnit,
    required this.purchaseDate,
    this.enabled = true,
  });

  final TextEditingController amount;
  final WarrantyUnit unit;
  final ValueChanged<WarrantyUnit> onUnit;
  final DateTime purchaseDate;
  final bool enabled;

  @override
  State<WarrantyDurationField> createState() => _WarrantyDurationFieldState();
}

class _WarrantyDurationFieldState extends State<WarrantyDurationField> {
  @override
  void initState() {
    super.initState();
    widget.amount.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.amount.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  int? get _value => int.tryParse(widget.amount.text.trim());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final months = widget.unit == WarrantyUnit.months;
    final amount = _value;
    final valid = isValidWarrantyAmount(amount, widget.unit);
    final helper = valid
        ? t.warrantyUntil(
            DateFormat.yMMMd(
              locale,
            ).format(warrantyEndOf(widget.purchaseDate, amount!, widget.unit)),
          )
        : (months ? t.warrantyMonthsRange : t.warrantyYearsMin);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: widget.amount,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            // Re-validates on every rebuild once touched, so switching
            // the unit clears a stale "1 to 12 months" error.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: t.warranty,
              helperText: helper,
              helperMaxLines: 2,
              prefixIcon: const Icon(Icons.verified_user_rounded),
            ),
            validator: (_) => isValidWarrantyAmount(_value, widget.unit)
                ? null
                : (months ? t.warrantyMonthsRange : t.warrantyYearsMin),
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: SegmentedButton<WarrantyUnit>(
            segments: [
              ButtonSegment(
                value: WarrantyUnit.months,
                label: Text(t.warrantyMonths),
              ),
              ButtonSegment(
                value: WarrantyUnit.years,
                label: Text(t.warrantyYears),
              ),
            ],
            selected: {widget.unit},
            showSelectedIcon: false,
            onSelectionChanged: widget.enabled
                ? (s) => widget.onUnit(s.first)
                : null,
          ),
        ),
      ],
    );
  }
}

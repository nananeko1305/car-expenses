import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../money/money.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/repair_repository.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/date_field.dart';
import '../widgets/money_fields.dart';

/// Create or edit a service. Anyone can view one; only its author or
/// the admin can change or delete it.
class RepairFormScreen extends StatefulWidget {
  const RepairFormScreen({
    super.key,
    required this.data,
    required this.profile,
    this.repair,
    this.initialVehicleId,
  });

  final LiveData data;
  final AppUser profile;
  final Repair? repair;
  final String? initialVehicleId;

  @override
  State<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends State<RepairFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Repair? _old = widget.repair;
  late final bool _canEdit =
      _old == null || widget.profile.canEdit(_old.ownerId);
  late String _vehicleId = _initialVehicle();
  late DateTime _date = _old?.date ?? DateUtils.dateOnly(DateTime.now());
  late Currency _currency = _old?.currency ?? Currency.rsd;
  late bool _toWallet = _old?.toWallet ?? true;
  late final _amount = TextEditingController(
    text: _old == null ? '' : moneyToInput(_old.amountMinor),
  );
  late final _mileage = TextEditingController(
    text: _old?.mileage?.toString() ?? '',
  );
  late final _description = TextEditingController(
    text: _old?.description ?? '',
  );

  String _initialVehicle() {
    final ids = widget.data.vehicles!.map((v) => v.id).toSet();
    for (final id in [widget.repair?.vehicleId, widget.initialVehicleId]) {
      if (id != null && ids.contains(id)) return id;
    }
    return widget.data.vehicles!.first.id;
  }

  @override
  void dispose() {
    _amount.dispose();
    _mileage.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final mileage = _mileage.text.trim();
    final repair = Repair(
      id: _old?.id ?? '',
      // Editing keeps the original author, even when the admin edits.
      ownerId: _old?.ownerId ?? widget.profile.uid,
      vehicleId: _vehicleId,
      date: _date,
      amountMinor: parseMoney(_amount.text)!,
      currency: _currency,
      description: _description.text.trim(),
      mileage: mileage.isEmpty ? null : int.parse(mileage),
      toWallet: _toWallet,
    );
    saveInBackground(context, () => RepairRepository.instance.save(repair));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    if (!await confirmDelete(context, t.deleteRepairQ) || !mounted) return;
    final id = _old!.id;
    saveInBackground(context, () => RepairRepository.instance.delete(id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vehicles = widget.data.vehicles!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_old == null ? t.newRepair : t.editRepair),
        actions: [
          if (_old != null && _canEdit)
            IconButton(
              tooltip: t.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_old != null) ...[_authorNote(t), const SizedBox(height: 14)],
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(16),
              initialValue: _vehicleId,
              decoration: InputDecoration(
                labelText: t.vehicle,
                prefixIcon: const Icon(Icons.directions_car_rounded),
              ),
              items: [
                for (final v in vehicles)
                  DropdownMenuItem(value: v.id, child: Text(v.label)),
              ],
              onChanged: _canEdit
                  ? (id) => setState(() => _vehicleId = id!)
                  : null,
            ),
            const SizedBox(height: 14),
            DateField(
              label: t.date,
              value: _date,
              enabled: _canEdit,
              onChanged: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 14),
            MoneyFields(
              amount: _amount,
              currency: _currency,
              enabled: _canEdit,
              onCurrency: (c) => setState(() => _currency = c),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _mileage,
              enabled: _canEdit,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t.mileage,
                helperText: t.mileageOptional,
                prefixIcon: const Icon(Icons.speed_rounded),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return null;
                final n = int.tryParse(s);
                return (n == null || n < 0) ? t.invalidNumber : null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              enabled: _canEdit,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.description,
                hintText: t.descriptionHint,
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.required : null,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.account_balance_wallet_rounded),
              title: Text(t.addToWallet),
              subtitle: Text(t.addToWalletHint),
              value: _toWallet,
              onChanged: _canEdit ? (v) => setState(() => _toWallet = v) : null,
            ),
            if (_canEdit) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: Text(t.save)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _authorNote(AppLocalizations t) {
    final name = widget.data.nameOf(_old!.ownerId);
    return Row(
      children: [
        const Icon(Icons.person_rounded, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(_canEdit ? t.enteredBy(name) : t.readOnlyNotice(name)),
        ),
      ],
    );
  }
}

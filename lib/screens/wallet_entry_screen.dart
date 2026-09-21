import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/wallet_entry.dart';
import '../money/money.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/wallet_repository.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/date_field.dart';
import '../widgets/money_fields.dart';

/// Add funds to, or spend from, the wallet: amount, what for, date and
/// who. Only the person who recorded it (or the admin) can change it.
class WalletEntryScreen extends StatefulWidget {
  const WalletEntryScreen({
    super.key,
    required this.data,
    required this.profile,
    required this.type,
    this.entry,
  });

  final LiveData data;
  final AppUser profile;
  final WalletEntryType type;
  final WalletEntry? entry;

  @override
  State<WalletEntryScreen> createState() => _WalletEntryScreenState();
}

class _WalletEntryScreenState extends State<WalletEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final WalletEntry? _old = widget.entry;
  late final bool _canEdit =
      _old == null || widget.profile.canEdit(_old.createdBy);
  late final bool _spending = widget.type == WalletEntryType.withdrawal;
  late DateTime _date = _old?.date ?? DateUtils.dateOnly(DateTime.now());
  late Currency _currency = _old?.currency ?? Currency.rsd;
  late String _userId = _old?.userId ?? widget.profile.uid;
  late final _amount = TextEditingController(
    text: _old == null ? '' : moneyToInput(_old.amountMinor),
  );
  late final _description = TextEditingController(
    text: _old?.description ?? '',
  );

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final entry = WalletEntry(
      id: _old?.id ?? '',
      type: widget.type,
      amountMinor: parseMoney(_amount.text)!,
      currency: _currency,
      description: _description.text.trim(),
      date: _date,
      userId: _userId,
      createdBy: _old?.createdBy ?? widget.profile.uid,
    );
    saveInBackground(context, () => WalletRepository.instance.save(entry));
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    if (!await confirmDelete(context, t.deleteEntryQ) || !mounted) return;
    final id = _old!.id;
    saveInBackground(context, () => WalletRepository.instance.delete(id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final users = widget.data.users!;
    final title = _old != null
        ? t.editEntry
        : (_spending ? t.newWithdrawal : t.newDeposit);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            if (!_canEdit) ...[
              Text(t.readOnlyNotice(widget.data.nameOf(_old!.createdBy))),
              const SizedBox(height: 14),
            ],
            MoneyFields(
              amount: _amount,
              currency: _currency,
              enabled: _canEdit,
              onCurrency: (c) => setState(() => _currency = c),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              enabled: _canEdit,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: _spending ? t.spentOn : t.depositNote,
                hintText: _spending ? null : t.depositNoteHint,
                alignLabelWithHint: true,
              ),
              // What the money was spent on is mandatory; a deposit note is not.
              validator: (v) => _spending && (v == null || v.trim().isEmpty)
                  ? t.required
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
            DropdownButtonFormField<String>(
              initialValue: users.any((u) => u.uid == _userId) ? _userId : null,
              decoration: InputDecoration(
                labelText: _spending ? t.spentBy : t.addedBy,
                prefixIcon: const Icon(Icons.person_rounded),
              ),
              items: [
                for (final u in users)
                  DropdownMenuItem(value: u.uid, child: Text(u.displayName)),
              ],
              onChanged: _canEdit
                  ? (id) => setState(() => _userId = id!)
                  : null,
              validator: (v) => v == null ? t.required : null,
            ),
            if (_canEdit) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: Text(t.save)),
            ],
          ],
        ),
      ),
    );
  }
}

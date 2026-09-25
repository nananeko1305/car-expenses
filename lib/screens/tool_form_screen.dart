import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/tool.dart';
import '../models/tool_draft.dart';
import '../models/wallet_entry.dart';
import '../money/money.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/tool_repository.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/date_field.dart';
import '../widgets/money_fields.dart';
import '../widgets/tool_fields.dart';
import 'wallet_entry_screen.dart';

/// Create or edit a tool.
///
/// Unlike services and wallet entries, a tool belongs to the workshop
/// rather than to whoever typed it in: anyone may correct a warranty or
/// add the receipt. Who entered it is still recorded, and a tool is
/// never deleted, only archived, so the spending that bought it is never
/// dragged along.
class ToolFormScreen extends StatefulWidget {
  const ToolFormScreen({
    super.key,
    required this.data,
    required this.profile,
    this.tool,
  });

  final LiveData data;
  final AppUser profile;
  final Tool? tool;

  @override
  State<ToolFormScreen> createState() => _ToolFormScreenState();
}

class _ToolFormScreenState extends State<ToolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Tool? _old = widget.tool;
  late final _draft = ToolDraft(tool: _old);
  late DateTime _date =
      _old?.purchaseDate ?? DateUtils.dateOnly(DateTime.now());
  late Currency _currency = _old?.currency ?? Currency.rsd;
  late final _amount = TextEditingController(
    text: _old?.amountMinor == null ? '' : moneyToInput(_old!.amountMinor!),
  );

  /// The wallet spending that bought it, when there is one; then the
  /// price is the wallet's business, not the tool form's.
  WalletEntry? get _entry => widget.data.entryById(_old?.entryId ?? '');

  @override
  void dispose() {
    _draft.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final tool = _draft.build(
      ownerId: _old?.ownerId ?? widget.profile.uid,
      purchaseDate: _date,
      id: _old?.id ?? '',
      entryId: _old?.entryId ?? '',
      amountMinor: _entry != null
          ? _old?.amountMinor
          : parseMoney(_amount.text),
      currency: _entry != null ? _old?.currency : _currency,
      archived: _old?.archived ?? false,
    );
    saveInBackground(context, () => ToolRepository.instance.save(tool));
    Navigator.of(context).pop();
  }

  Future<void> _toggleArchive() async {
    final t = AppLocalizations.of(context);
    final tool = _old!;
    if (!tool.archived) {
      final ok = await confirmDelete(
        context,
        t.archiveToolQ(tool.name),
        body: t.archiveToolBody,
        confirmLabel: t.archive,
      );
      if (!ok || !mounted) return;
    }
    saveInBackground(
      context,
      () => ToolRepository.instance.setArchived(tool.id, !tool.archived),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final entry = _entry;
    return Scaffold(
      appBar: AppBar(
        title: Text(_old == null ? t.newTool : t.editTool),
        actions: [
          if (_old != null)
            IconButton(
              tooltip: _old.archived ? t.unarchive : t.archive,
              icon: Icon(
                _old.archived
                    ? Icons.unarchive_rounded
                    : Icons.archive_outlined,
              ),
              onPressed: _toggleArchive,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_old != null) ...[
              Row(
                children: [
                  const Icon(Icons.person_rounded, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(t.enteredBy(widget.data.nameOf(_old.ownerId))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            ToolFields(
              draft: _draft,
              purchaseDate: _date,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 6),
            DateField(
              label: t.purchaseDate,
              value: _date,
              onChanged: (d) => setState(() => _date = d),
            ),
            const SizedBox(height: 14),
            if (entry == null)
              MoneyFields(
                amount: _amount,
                currency: _currency,
                optional: true,
                helperText: t.toolPriceOptional,
                onCurrency: (c) => setState(() => _currency = c),
              )
            else
              _entryTile(t, entry),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: Text(t.save)),
          ],
        ),
      ),
    );
  }

  Widget _entryTile(AppLocalizations t, WalletEntry entry) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_rounded),
        title: Text(formatMoney(entry.amountMinor, entry.currency, locale)),
        subtitle: Text(t.openWalletEntry),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WalletEntryScreen(
              data: widget.data,
              profile: widget.profile,
              type: entry.type,
              entry: entry,
            ),
          ),
        ),
      ),
    );
  }
}

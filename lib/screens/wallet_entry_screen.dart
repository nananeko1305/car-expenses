import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/tool.dart';
import '../models/tool_draft.dart';
import '../models/wallet_entry.dart';
import '../money/money.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/purchase_repository.dart';
import '../services/wallet_repository.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/date_field.dart';
import '../widgets/money_fields.dart';
import '../widgets/option_sheet.dart';
import '../widgets/picker_field.dart';
import '../widgets/spending_tool_section.dart';
import 'tool_form_screen.dart';

/// Add funds to, or spend from, the wallet: amount, what for, date and
/// who. Only the person who recorded it (or the admin) can change it.
///
/// Spending can record the tool it bought in the same go. That only
/// happens while creating the entry — offering it on an edit as well
/// would make every save produce another tool.
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
  late final _tool = ToolDraft();
  bool _addTool = true;

  /// Everything that is not consumable is a tool, so the switch starts on.
  bool get _buyingTool => _spending && _old == null && _addTool;

  /// The tool this spending already bought, when editing one.
  Tool? get _boughtTool => widget.data.toolForEntry(_old?.id ?? '');

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _tool.dispose();
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
    final tool = _buyingTool
        ? _tool.build(
            ownerId: widget.profile.uid,
            purchaseDate: _date,
            amountMinor: parseMoney(_amount.text),
            currency: _currency,
          )
        : null;
    saveInBackground(
      context,
      tool == null
          ? () => WalletRepository.instance.save(entry)
          : () => PurchaseRepository.instance.savePurchase(
              entry: entry,
              tool: tool,
            ),
    );
    Navigator.of(context).pop();
  }

  void _openTool() {
    final tool = _boughtTool;
    if (tool == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToolFormScreen(
          data: widget.data,
          profile: widget.profile,
          tool: tool,
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final id = _old!.id;
    try {
      // The tool would be left pointing at nothing, and tools stay.
      if (await PurchaseRepository.instance.hasTool(id)) {
        messenger.showSnackBar(SnackBar(content: Text(t.entryHasTool)));
        return;
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorText(t, e))));
      return;
    }
    if (!mounted) return;
    if (!await confirmDelete(context, t.deleteEntryQ) || !mounted) return;
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
            PickerField(
              label: _spending ? t.spentBy : t.addedBy,
              icon: Icons.person_rounded,
              value: _userId,
              enabled: _canEdit,
              options: [
                for (final u in users)
                  SheetOption(
                    id: u.uid,
                    label: u.displayName,
                    subtitle: u.email,
                  ),
              ],
              onChanged: (id) => setState(() => _userId = id),
            ),
            SpendingToolSection(
              draft: _tool,
              purchaseDate: _date,
              addTool: _spending && _old == null ? _addTool : null,
              onAddTool: (v) => setState(() => _addTool = v),
              onChanged: () => setState(() {}),
              bought: _spending ? _boughtTool : null,
              onOpenTool: _openTool,
              enabled: _canEdit,
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

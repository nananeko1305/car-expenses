import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tool_draft.dart';
import '../models/warranty.dart';
import 'warranty_duration_field.dart';

/// What a tool needs beyond its price and purchase date: what it is, how
/// long the warranty runs, and whether to remind anyone before it ends.
///
/// Used both inline on the spending form and on the tool form itself.
class ToolFields extends StatelessWidget {
  const ToolFields({
    super.key,
    required this.draft,
    required this.purchaseDate,
    required this.onChanged,
    this.enabled = true,
  });

  final ToolDraft draft;
  final DateTime purchaseDate;

  /// Called after the unit or the reminder switch changes, so the owning
  /// form can rebuild.
  final VoidCallback onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        TextFormField(
          controller: draft.name,
          enabled: enabled,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: t.toolName,
            hintText: t.toolNameHint,
            prefixIcon: const Icon(Icons.handyman_rounded),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? t.required : null,
        ),
        const SizedBox(height: 14),
        WarrantyDurationField(
          amount: draft.warranty,
          unit: draft.unit,
          purchaseDate: purchaseDate,
          enabled: enabled,
          onUnit: (u) {
            draft.unit = u;
            onChanged();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_active_rounded),
          title: Text(t.notifyOnExpiry),
          subtitle: Text(t.notifyOnExpiryHint),
          value: draft.notify,
          onChanged: enabled
              ? (v) {
                  draft.notify = v;
                  onChanged();
                }
              : null,
        ),
      ],
    );
  }
}

/// Whether the draft currently describes a tool that can be saved. The
/// form's own validator covers the fields; this guards the number that
/// [ToolDraft.build] parses.
bool isCompleteToolDraft(ToolDraft draft) =>
    draft.name.text.trim().isNotEmpty &&
    isValidWarrantyAmount(int.tryParse(draft.warranty.text.trim()), draft.unit);

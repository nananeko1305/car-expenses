import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tool.dart';
import '../models/tool_draft.dart';
import 'tool_card.dart';
import 'tool_fields.dart';

/// The tool half of the spending form.
///
/// While the spending is being created it offers to record the tool it
/// bought; once the spending exists it shows the tool it did buy and
/// leads to it. It is never both: offering the fields on an edit would
/// make every save produce another tool.
class SpendingToolSection extends StatelessWidget {
  const SpendingToolSection({
    super.key,
    required this.draft,
    required this.purchaseDate,
    required this.addTool,
    required this.onAddTool,
    required this.onChanged,
    this.bought,
    this.onOpenTool,
    this.enabled = true,
  });

  final ToolDraft draft;
  final DateTime purchaseDate;

  /// Whether the switch is on. Null means the spending already exists,
  /// so there is nothing left to offer.
  final bool? addTool;
  final ValueChanged<bool>? onAddTool;
  final VoidCallback onChanged;

  /// The tool this spending bought, when it bought one.
  final Tool? bought;
  final VoidCallback? onOpenTool;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final adding = addTool;
    if (adding == null) {
      final tool = bought;
      if (tool == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: ToolCard(
          tool: tool,
          now: DateUtils.dateOnly(DateTime.now()),
          onTap: onOpenTool ?? () {},
        ),
      );
    }
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.handyman_rounded),
          title: Text(t.addToTools),
          subtitle: Text(t.addToToolsHint),
          value: adding,
          onChanged: enabled ? onAddTool : null,
        ),
        if (adding)
          ToolFields(
            draft: draft,
            purchaseDate: purchaseDate,
            enabled: enabled,
            onChanged: onChanged,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/ui_choice.dart';
import '../theme/app_colors.dart';

/// New or classic, side by side: which of the app's two interfaces this
/// phone shows. Choosing one closes Settings, since the whole app is
/// drawn again in the other one.
class UiStylePicker extends StatelessWidget {
  const UiStylePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UiStyle value;
  final ValueChanged<UiStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<UiStyle>(
          segments: [
            ButtonSegment(
              value: UiStyle.leaning,
              icon: const Icon(Icons.speed_rounded),
              label: Text(t.uiStyleNew),
            ),
            ButtonSegment(
              value: UiStyle.classic,
              icon: const Icon(Icons.history_rounded),
              label: Text(t.uiStyleClassic),
            ),
          ],
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onChanged(s.first),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            t.uiStyleHint,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.ink.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }
}

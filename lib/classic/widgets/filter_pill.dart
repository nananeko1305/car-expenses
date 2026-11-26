import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'option_sheet.dart';

/// Rounded filter button. Shows the current choice, turns accent-colored
/// while a filter is active (with an x to clear it), and opens an option
/// sheet to pick a value. A null [value] means "all".
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.icon,
    required this.title,
    required this.allLabel,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;

  /// Sheet heading, e.g. "Car".
  final String title;
  final String allLabel;
  final String? value;
  final List<SheetOption> options;
  final ValueChanged<String?> onChanged;

  SheetOption? get _selected {
    for (final o in options) {
      if (o.id == value) return o;
    }
    return null;
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showOptionSheet(
      context,
      icon: icon,
      title: title,
      allLabel: allLabel,
      value: _selected?.id,
      options: options,
    );
    if (picked != null) onChanged(picked.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = _selected;
    final active = selected != null;
    final fg = active ? Colors.white : c.ink;

    return Material(
      color: active ? c.primary : c.surface,
      shape: StadiumBorder(
        side: active
            ? BorderSide.none
            : BorderSide(color: c.ink.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: active ? fg : c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selected?.shortLabel ?? selected?.label ?? allLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
              if (active)
                InkResponse(
                  radius: 18,
                  onTap: () => onChanged(null),
                  child: Icon(Icons.close_rounded, size: 20, color: fg),
                )
              else
                Icon(Icons.expand_more_rounded, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One choice in a [FilterPill] sheet.
class FilterOption {
  const FilterOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.shortLabel,
  });

  final String id;
  final String label;

  /// Shown on the pill instead of [label] when set (e.g. just the plate).
  final String? shortLabel;

  /// Secondary line, e.g. "3 services".
  final String? subtitle;
}

/// Rounded filter button. Shows the current choice, turns accent-colored
/// while a filter is active (with an x to clear it), and opens a bottom
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
  final List<FilterOption> options;
  final ValueChanged<String?> onChanged;

  FilterOption? get _selected {
    for (final o in options) {
      if (o.id == value) return o;
    }
    return null;
  }

  Future<void> _open(BuildContext context) async {
    // Wrapped so "all" (null) can be told apart from a dismissed sheet.
    final picked = await showModalBottomSheet<({String? id})>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _FilterSheet(
        icon: icon,
        title: title,
        allLabel: allLabel,
        value: _selected?.id,
        options: options,
      ),
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

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.icon,
    required this.title,
    required this.allLabel,
    required this.value,
    required this.options,
  });

  final IconData icon;
  final String title;
  final String allLabel;
  final String? value;
  final List<FilterOption> options;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                children: [
                  _tile(context, null, allLabel, null, Icons.apps_rounded),
                  for (final o in options)
                    _tile(context, o.id, o.label, o.subtitle, icon),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String? id,
    String label,
    String? subtitle,
    IconData leading,
  ) {
    final c = context.colors;
    final selected = id == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: selected ? c.soft : null,
        leading: CircleAvatar(
          backgroundColor: selected ? c.primary : c.soft,
          foregroundColor: selected ? Colors.white : c.primary,
          child: Icon(leading, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: selected
            ? Icon(Icons.check_circle_rounded, color: c.primary)
            : null,
        onTap: () => Navigator.pop(context, (id: id)),
      ),
    );
  }
}

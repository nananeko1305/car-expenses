import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One choice in an option sheet.
class SheetOption {
  const SheetOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.shortLabel,
  });

  final String id;
  final String label;

  /// Shown on a compact control instead of [label] (e.g. just the plate).
  final String? shortLabel;

  /// Secondary line, e.g. "3 services".
  final String? subtitle;
}

/// Rounded bottom sheet listing [options] with icons, subtitles and a
/// check on [value]. With [allLabel], a first "all" row maps to null.
///
/// Returns null when dismissed, otherwise a record whose `id` is the
/// picked option (or null for "all") — so "all" and "dismissed" differ.
Future<({String? id})?> showOptionSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required List<SheetOption> options,
  String? value,
  String? allLabel,
}) {
  return showModalBottomSheet<({String? id})>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _OptionSheet(
      icon: icon,
      title: title,
      options: options,
      value: value,
      allLabel: allLabel,
    ),
  );
}

class _OptionSheet extends StatelessWidget {
  const _OptionSheet({
    required this.icon,
    required this.title,
    required this.options,
    required this.value,
    required this.allLabel,
  });

  final IconData icon;
  final String title;
  final List<SheetOption> options;
  final String? value;
  final String? allLabel;

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
                  if (allLabel != null)
                    _tile(context, null, allLabel!, null, Icons.apps_rounded),
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

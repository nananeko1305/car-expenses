import 'package:flutter/material.dart';

import 'option_sheet.dart';

/// Form field that looks like the other inputs (label, icon, rounded
/// border) but picks its value from an option sheet instead of a
/// dropdown menu.
class PickerField extends StatelessWidget {
  const PickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<SheetOption> options;
  final ValueChanged<String> onChanged;
  final bool enabled;

  Future<void> _open(BuildContext context) async {
    final picked = await showOptionSheet(
      context,
      icon: icon,
      title: label,
      value: value,
      options: options,
    );
    final id = picked?.id;
    if (id != null) onChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    SheetOption? selected;
    for (final o in options) {
      if (o.id == value) selected = o;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled ? () => _open(context) : null,
      child: InputDecorator(
        isEmpty: selected == null,
        decoration: InputDecoration(
          labelText: label,
          enabled: enabled,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: selected == null
            ? null
            : Text(
                selected.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}

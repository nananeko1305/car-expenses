import 'package:flutter/material.dart';

/// Compact dropdown used for list filters. A null value means "all".
class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.icon,
    required this.allLabel,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String allLabel;
  final String? value;

  /// id -> label.
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: options.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(allLabel)),
        for (final e in options.entries)
          DropdownMenuItem(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

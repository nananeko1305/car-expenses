import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One destination of the bottom bar.
typedef RaceNavItem = ({IconData icon, String label});

/// The bottom bar: an icon and a leaning label per destination, the open
/// one in the accent with a bar across its top.
class RaceNavBar extends StatelessWidget {
  const RaceNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
  });

  final List<RaceNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.background,
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.line)),
          ),
          child: Row(
            children: [
              for (final (i, item) in items.indexed)
                Expanded(child: _item(c, i, item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(AppColors c, int i, RaceNavItem item) {
    final selected = i == index;
    final color = selected ? c.accentText : c.muted;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: () => onChanged(i),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: selected ? c.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                item.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

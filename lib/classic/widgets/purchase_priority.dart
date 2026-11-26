import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/planned_purchase.dart';
import '../theme/app_colors.dart';

/// What a priority is called: "Urgent", "Medium" or "Not urgent".
String priorityLabel(AppLocalizations t, PurchasePriority priority) =>
    switch (priority) {
      PurchasePriority.high => t.priorityHigh,
      PurchasePriority.medium => t.priorityMedium,
      PurchasePriority.low => t.priorityLow,
    };

/// How a priority is drawn: red for urgent, yellow for medium and green
/// for not urgent, the same in the light and the dark theme. Each comes
/// with the color that stays readable on it, which on yellow is dark.
({Color background, Color foreground, IconData icon}) _look(
  PurchasePriority priority,
) => switch (priority) {
  PurchasePriority.high => (
    background: const Color(0xFFC93A3A),
    foreground: Colors.white,
    icon: Icons.priority_high_rounded,
  ),
  PurchasePriority.medium => (
    background: const Color(0xFFF2C230),
    foreground: const Color(0xFF3A2E00),
    icon: Icons.drag_handle_rounded,
  ),
  PurchasePriority.low => (
    background: const Color(0xFF2E7D4F),
    foreground: Colors.white,
    icon: Icons.arrow_downward_rounded,
  ),
};

/// The priority of one item, as a label in its color: what a card on the
/// to-buy list carries.
class PriorityPill extends StatelessWidget {
  const PriorityPill(this.priority, {super.key});

  final PurchasePriority priority;

  @override
  Widget build(BuildContext context) {
    final look = _look(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: look.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priorityLabel(AppLocalizations.of(context), priority),
        style: TextStyle(
          color: look.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A round mark for a priority, for the picker. Each one differs in its
/// sign as well as its color, so it reads without telling red from green;
/// the name is always next to it, which is why screen readers skip it.
class PriorityMark extends StatelessWidget {
  const PriorityMark(this.priority, {super.key, this.radius = 20});

  final PurchasePriority priority;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final look = _look(priority);
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: look.background,
        foregroundColor: look.foreground,
        child: Icon(look.icon, size: radius),
      ),
    );
  }
}

/// The three priorities, one under another, with [value] ticked. A row
/// each, since three long Serbian names do not fit side by side.
class PriorityPicker extends StatelessWidget {
  const PriorityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PurchasePriority value;
  final ValueChanged<PurchasePriority> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Text(
            t.priority,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.ink.withValues(alpha: 0.65),
            ),
          ),
        ),
        for (final priority in PurchasePriority.mostUrgentFirst)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            selected: priority == value,
            textColor: c.ink,
            selectedColor: c.ink,
            selectedTileColor: c.soft.withValues(alpha: 0.6),
            leading: PriorityMark(priority, radius: 16),
            title: Text(
              priorityLabel(t, priority),
              style: TextStyle(
                fontWeight: priority == value
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
            trailing: priority == value
                ? Icon(Icons.check_circle_rounded, color: c.primary)
                : null,
            onTap: () => onChanged(priority),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/plate_chip.dart';
import '../widgets/race_row.dart';
import '../widgets/skewed.dart';
import 'vehicle_history_screen.dart';

/// Search cars by license plate (or name); tapping one opens its
/// service history.
class VehicleSearchScreen extends StatefulWidget {
  const VehicleSearchScreen({
    super.key,
    required this.data,
    required this.profile,
  });

  final LiveData data;
  final AppUser profile;

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: t.searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(_query.clear),
                  ),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.data,
        builder: (context, _) {
          final results = (widget.data.vehicles ?? const [])
              .where((v) => v.matches(_query.text))
              .toList();
          if (results.isEmpty) {
            return Center(child: Text(t.noResults));
          }
          final repairs = widget.data.repairs ?? const [];
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox.shrink(),
            itemBuilder: (context, i) {
              final v = results[i];
              final count = repairs.where((r) => r.vehicleId == v.id).length;
              return RaceRow(
                leading: const SkewIcon(Icons.directions_car_rounded),
                title: v.name,
                below: Row(
                  children: [
                    if (v.plate.isNotEmpty) ...[
                      PlateChip(v.plate, fontSize: 13),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      t.repairsCount(count),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.muted,
                      ),
                    ),
                  ],
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.muted,
                  ),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VehicleHistoryScreen(
                      data: widget.data,
                      profile: widget.profile,
                      vehicleId: v.id,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

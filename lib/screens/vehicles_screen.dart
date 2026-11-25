import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../models/vehicle.dart';
import '../services/background_save.dart';
import '../services/live_data.dart';
import '../services/vehicle_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/confirm_delete.dart';
import '../widgets/plate_chip.dart';
import '../widgets/race_row.dart';
import '../widgets/skewed.dart';
import '../widgets/slant_header.dart';
import '../widgets/sync_banner.dart';
import '../widgets/vehicle_dialog.dart';
import 'vehicle_history_screen.dart';

/// Shared list of cars. Tapping one opens its service history. Anyone
/// can add a car; only whoever added it (or the admin) can edit or
/// delete it, and only while it has no services.
class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  Future<void> _delete(BuildContext context, Vehicle vehicle) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await VehicleRepository.instance.hasRepairs(vehicle.id)) {
        messenger.showSnackBar(SnackBar(content: Text(t.vehicleHasServices)));
        return;
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(errorText(t, e))));
      return;
    }
    if (!context.mounted) return;
    final ok = await confirmDelete(
      context,
      t.deleteVehicleQ(vehicle.label),
      body: t.deleteVehicleBody,
    );
    if (!ok || !context.mounted) return;
    saveInBackground(
      context,
      () => VehicleRepository.instance.delete(vehicle.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: SlantAppBar(title: t.vehicles),
      floatingActionButton: SkewFab(
        onPressed: () => showVehicleDialog(context, ownerId: profile.uid),
        icon: Icons.add_rounded,
        label: t.addVehicle,
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: ListenableBuilder(
              listenable: data,
              builder: (context, _) {
                final vehicles = data.vehicles ?? const <Vehicle>[];
                if (vehicles.isEmpty) {
                  return Center(child: Text(t.noVehicles));
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, _) => const SizedBox.shrink(),
                  itemBuilder: (context, i) => _tile(context, t, vehicles[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, AppLocalizations t, Vehicle v) {
    final c = context.colors;
    final canEdit = profile.canEdit(v.ownerId);
    return RaceRow(
      leading: const SkewIcon(Icons.directions_car_rounded),
      title: v.name,
      below: Row(
        children: [
          if (v.plate.isNotEmpty) ...[
            PlateChip(v.plate),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              data.nameOf(v.ownerId),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: c.muted),
            ),
          ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VehicleHistoryScreen(
            data: data,
            profile: profile,
            vehicleId: v.id,
          ),
        ),
      ),
      trailing: canEdit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: t.edit,
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => showVehicleDialog(
                    context,
                    ownerId: v.ownerId,
                    vehicle: v,
                  ),
                ),
                IconButton(
                  tooltip: t.delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _delete(context, v),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right_rounded, color: c.muted),
            ),
    );
  }
}

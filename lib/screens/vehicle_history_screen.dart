import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/vehicle.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/plate_chip.dart';
import '../widgets/repair_card.dart';
import '../widgets/skewed.dart';
import '../widgets/slant_header.dart';
import '../widgets/totals_card.dart';
import '../widgets/vehicle_dialog.dart';
import 'repair_form_screen.dart';

/// One car: plate, name, last mileage, totals and its full service
/// history (newest first). Stays live while open.
class VehicleHistoryScreen extends StatelessWidget {
  const VehicleHistoryScreen({
    super.key,
    required this.data,
    required this.profile,
    required this.vehicleId,
  });

  final LiveData data;
  final AppUser profile;
  final String vehicleId;

  void _openForm(BuildContext context, [Repair? repair]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepairFormScreen(
          data: data,
          profile: profile,
          repair: repair,
          initialVehicleId: vehicleId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final vehicle = data.vehicleById(vehicleId);
        if (vehicle == null) {
          // Deleted while open.
          return Scaffold(
            appBar: const SlantAppBar(title: ''),
            body: Center(child: Text(t.noVehicles)),
          );
        }
        final repairs = data.repairs!
            .where((r) => r.vehicleId == vehicleId)
            .toList();
        return Scaffold(
          appBar: SlantAppBar(
            title: t.serviceHistory,
            actions: [
              if (profile.canEdit(vehicle.ownerId))
                IconButton(
                  tooltip: t.edit,
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => showVehicleDialog(
                    context,
                    ownerId: vehicle.ownerId,
                    vehicle: vehicle,
                  ),
                ),
            ],
          ),
          floatingActionButton: SkewFab(
            onPressed: () => _openForm(context),
            icon: Icons.add_rounded,
            label: t.newRepair,
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _header(context, t, vehicle, repairs),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: TotalsCard(repairs: repairs),
              ),
              Divider(height: 1, color: context.colors.line),
              if (repairs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(t.noServicesForCar, textAlign: TextAlign.center),
                ),
              for (final r in repairs) ...[
                RepairCard(
                  repair: r,
                  vehicle: null,
                  authorName: data.nameOf(r.ownerId),
                  onTap: () => _openForm(context, r),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _header(
    BuildContext context,
    AppLocalizations t,
    Vehicle vehicle,
    List<Repair> repairs,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // Newest service that has a mileage recorded.
    final withKm = repairs.where((r) => r.mileage != null);
    final lastKm = withKm.isEmpty ? null : withKm.first.mileage;
    final c = context.colors;
    final quiet = TextStyle(fontSize: 13, color: c.muted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (vehicle.plate.isNotEmpty) ...[
                PlateChip(vehicle.plate, fontSize: 18),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  vehicle.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (vehicle.vin.isNotEmpty) ...[
            const SizedBox(height: 6),
            // Selectable, so it can be copied when ordering parts.
            SelectableText('${t.vinShort}: ${vehicle.vin}', style: quiet),
          ],
          if (lastKm != null) ...[
            const SizedBox(height: 2),
            Text(
              '${t.lastMileage}: '
              '${NumberFormat.decimalPattern(locale).format(lastKm)} km',
              style: quiet,
            ),
          ],
        ],
      ),
    );
  }
}

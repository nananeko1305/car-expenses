import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/vehicle.dart';
import '../services/live_data.dart';
import '../theme/app_theme.dart';
import '../widgets/repair_card.dart';
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
            appBar: AppBar(),
            body: Center(child: Text(t.noVehicles)),
          );
        }
        final repairs = data.repairs!
            .where((r) => r.vehicleId == vehicleId)
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(t.serviceHistory),
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
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'history-fab',
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(t.newRepair),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _header(context, t, vehicle, repairs),
              const SizedBox(height: 12),
              TotalsCard(repairs: repairs),
              const SizedBox(height: 16),
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
                const SizedBox(height: 10),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.peach,
              foregroundColor: AppTheme.terracotta,
              child: const Icon(Icons.directions_car_rounded, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vehicle.plate.isNotEmpty)
                    Text(
                      vehicle.plate,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (lastKm != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${t.lastMileage}: '
                      '${NumberFormat.decimalPattern(locale).format(lastKm)} km',
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

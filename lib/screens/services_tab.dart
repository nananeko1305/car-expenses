import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../services/live_data.dart';
import '../widgets/filter_pill.dart';
import '../widgets/repair_card.dart';
import '../widgets/totals_card.dart';
import '../widgets/vehicle_dialog.dart';
import 'repair_form_screen.dart';

/// Every service from every user, filterable by car and by person.
class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  String? _vehicleId;
  String? _userId;

  LiveData get _data => widget.data;

  void _openForm([Repair? repair]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RepairFormScreen(
          data: _data,
          profile: widget.profile,
          repair: repair,
          initialVehicleId: _vehicleId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final vehicles = _data.vehicles!;
    // Services per car / per person, shown in the filter sheets.
    final perVehicle = <String, int>{};
    final perUser = <String, int>{};
    for (final r in _data.repairs!) {
      perVehicle[r.vehicleId] = (perVehicle[r.vehicleId] ?? 0) + 1;
      perUser[r.ownerId] = (perUser[r.ownerId] ?? 0) + 1;
    }
    final repairs = _data.repairs!
        .where((r) => _vehicleId == null || r.vehicleId == _vehicleId)
        .where((r) => _userId == null || r.ownerId == _userId)
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'services-fab',
        onPressed: vehicles.isEmpty
            ? () => showVehicleDialog(context, ownerId: widget.profile.uid)
            : _openForm,
        icon: const Icon(Icons.add_rounded),
        label: Text(vehicles.isEmpty ? t.addVehicle : t.newRepair),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          Row(
            children: [
              Expanded(
                child: FilterPill(
                  icon: Icons.directions_car_rounded,
                  title: t.vehicle,
                  allLabel: t.allVehicles,
                  value: _vehicleId,
                  options: [
                    for (final v in vehicles)
                      FilterOption(
                        id: v.id,
                        label: v.label,
                        shortLabel: v.plate.isEmpty ? v.name : v.plate,
                        subtitle: t.repairsCount(perVehicle[v.id] ?? 0),
                      ),
                  ],
                  onChanged: (id) => setState(() => _vehicleId = id),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilterPill(
                  icon: Icons.person_rounded,
                  title: t.person,
                  allLabel: t.allPeople,
                  value: _userId,
                  options: [
                    for (final u in _data.users!)
                      FilterOption(
                        id: u.uid,
                        label: u.displayName,
                        subtitle: t.repairsCount(perUser[u.uid] ?? 0),
                      ),
                  ],
                  onChanged: (id) => setState(() => _userId = id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TotalsCard(repairs: repairs),
          const SizedBox(height: 16),
          if (vehicles.isEmpty)
            _centered(t.noVehiclesYet)
          else if (repairs.isEmpty)
            _centered(t.noRepairs),
          for (final r in repairs) ...[
            RepairCard(
              repair: r,
              vehicle: _data.vehicleById(r.vehicleId),
              authorName: _data.nameOf(r.ownerId),
              onTap: () => _openForm(r),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _centered(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Text(text, textAlign: TextAlign.center),
  );
}

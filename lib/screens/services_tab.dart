import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/repair.dart';
import '../models/report.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/earnings_card.dart';
import '../widgets/filter_pill.dart';
import '../widgets/option_sheet.dart';
import '../widgets/repair_card.dart';
import '../widgets/skewed.dart';
import '../widgets/slant_header.dart';
import '../widgets/vehicle_dialog.dart';
import 'repair_form_screen.dart';
import 'report_screen.dart';

/// This month's services from every user, filterable by car and by
/// person. The header block carries what they earned and leads to the
/// report, where the earlier months are.
class ServicesTab extends StatefulWidget {
  const ServicesTab({
    super.key,
    required this.data,
    required this.profile,
    required this.onSearch,
  });

  final LiveData data;
  final AppUser profile;

  /// Opens the search by plate, from the header.
  final VoidCallback onSearch;

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
    // Only this month's services; earlier ones are in the monthly report.
    final now = DateTime.now();
    final thisMonth = _data.repairs!
        .where((r) => inMonth(r.date, now))
        .toList();
    // Services per car / per person, shown in the filter sheets.
    final perVehicle = <String, int>{};
    final perUser = <String, int>{};
    for (final r in thisMonth) {
      perVehicle[r.vehicleId] = (perVehicle[r.vehicleId] ?? 0) + 1;
      perUser[r.ownerId] = (perUser[r.ownerId] ?? 0) + 1;
    }
    final repairs = thisMonth
        .where((r) => _vehicleId == null || r.vehicleId == _vehicleId)
        .where((r) => _userId == null || r.ownerId == _userId)
        .toList();

    final locale = Localizations.localeOf(context).toLanguageTag();
    return Scaffold(
      floatingActionButton: SkewButton(
        label: vehicles.isEmpty ? t.addVehicle : t.newRepair,
        icon: Icons.add_rounded,
        height: 50,
        fontSize: 16,
        elevation: 4,
        onPressed: vehicles.isEmpty
            ? () => showVehicleDialog(context, ownerId: widget.profile.uid)
            : _openForm,
      ),
      body: Column(
        children: [
          SlantHeader(
            title: t.repairs,
            subtitle: DateFormat.yMMMM(locale).format(now),
            actions: [
              IconButton(
                tooltip: t.searchPlate,
                icon: const Icon(Icons.search_rounded),
                onPressed: widget.onSearch,
              ),
            ],
            child: EarningsCard(
              repairs: repairs,
              onOpenReport: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ReportScreen(data: _data, profile: widget.profile),
                ),
              ),
            ),
          ),
          Padding(
            // The filters lean, so they need room at both ends.
            padding: const EdgeInsets.fromLTRB(20, 0, 22, 8),
            child: Row(
              children: [
                Expanded(
                  child: FilterPill(
                    icon: Icons.directions_car_rounded,
                    title: t.vehicle,
                    allLabel: t.allVehicles,
                    value: _vehicleId,
                    options: [
                      for (final v in vehicles)
                        SheetOption(
                          id: v.id,
                          label: v.label,
                          shortLabel: v.plate.isEmpty ? v.name : v.plate,
                          subtitle: t.repairsCount(perVehicle[v.id] ?? 0),
                        ),
                    ],
                    onChanged: (id) => setState(() => _vehicleId = id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterPill(
                    icon: Icons.person_rounded,
                    title: t.person,
                    allLabel: t.allPeople,
                    value: _userId,
                    options: [
                      for (final u in _data.users!)
                        SheetOption(
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
          ),
          Divider(height: 1, color: context.colors.line),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (vehicles.isEmpty)
                  _centered(t.noVehiclesYet)
                else if (_data.repairs!.isEmpty)
                  _centered(t.noRepairs)
                else if (repairs.isEmpty)
                  _centered(t.noRepairsThisMonth),
                for (final r in repairs)
                  RepairCard(
                    repair: r,
                    vehicle: _data.vehicleById(r.vehicleId),
                    authorName: _data.nameOf(r.ownerId),
                    onTap: () => _openForm(r),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _centered(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
    child: Text(text, textAlign: TextAlign.center),
  );
}

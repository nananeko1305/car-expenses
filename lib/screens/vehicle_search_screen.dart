import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../services/live_data.dart';
import '../theme/app_theme.dart';
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
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final v = results[i];
              final count = repairs.where((r) => r.vehicleId == v.id).length;
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.peach,
                    foregroundColor: AppTheme.terracotta,
                    child: const Icon(Icons.directions_car_rounded),
                  ),
                  title: Text(
                    v.plate.isEmpty ? v.name : v.plate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Text('${v.name} · ${t.repairsCount(count)}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VehicleHistoryScreen(
                        data: widget.data,
                        profile: widget.profile,
                        vehicleId: v.id,
                      ),
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

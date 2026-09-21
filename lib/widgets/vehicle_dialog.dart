import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/vehicle.dart';
import '../services/background_save.dart';
import '../services/vehicle_repository.dart';

/// Dialog to add a car, or edit [vehicle] when given.
Future<void> showVehicleDialog(
  BuildContext context, {
  required String ownerId,
  Vehicle? vehicle,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _VehicleDialog(ownerId: ownerId, vehicle: vehicle),
  );
}

class _VehicleDialog extends StatefulWidget {
  const _VehicleDialog({required this.ownerId, this.vehicle});

  final String ownerId;
  final Vehicle? vehicle;

  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.vehicle?.name ?? '');
  late final _plate = TextEditingController(text: widget.vehicle?.plate ?? '');

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final vehicle = Vehicle(
      id: widget.vehicle?.id ?? '',
      ownerId: widget.ownerId,
      name: _name.text.trim(),
      plate: _plate.text.trim().toUpperCase(),
    );
    saveInBackground(context, () => VehicleRepository.instance.save(vehicle));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.vehicle == null ? t.newVehicle : t.editVehicle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t.vehicleName,
                hintText: t.vehicleNameHint,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _plate,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: t.plate,
                hintText: t.plateHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        TextButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../services/appointment_repository.dart';
import '../services/background_save.dart';
import 'confirm_delete.dart';
import 'date_field.dart';

/// Dialog to book something on [day], or to see [appointment], written
/// by [authorName]. Only its author or the admin may change or delete
/// one; anyone else reads it.
Future<void> showAppointmentDialog(
  BuildContext context, {
  required AppUser profile,
  required DateTime day,
  Appointment? appointment,
  String authorName = '',
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AppointmentDialog(
      profile: profile,
      day: day,
      appointment: appointment,
      authorName: authorName,
    ),
  );
}

class _AppointmentDialog extends StatefulWidget {
  const _AppointmentDialog({
    required this.profile,
    required this.day,
    required this.authorName,
    this.appointment,
  });

  final AppUser profile;
  final DateTime day;
  final String authorName;
  final Appointment? appointment;

  @override
  State<_AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<_AppointmentDialog> {
  /// The rules allow 500 characters.
  static const _maxLength = 500;

  final _formKey = GlobalKey<FormState>();
  late final Appointment? _old = widget.appointment;
  late final bool _canEdit =
      _old == null || widget.profile.canEdit(_old.ownerId);
  late DateTime _date = _old?.date ?? widget.day;
  late final _text = TextEditingController(text: _old?.text ?? '');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final appointment = Appointment(
      id: _old?.id ?? '',
      // Editing keeps the original author, even when the admin edits.
      ownerId: _old?.ownerId ?? widget.profile.uid,
      date: _date,
      text: _text.text.trim(),
    );
    saveInBackground(
      context,
      () => AppointmentRepository.instance.save(appointment),
    );
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final t = AppLocalizations.of(context);
    if (!await confirmDelete(context, t.deleteAppointmentQ) || !mounted) return;
    final id = _old!.id;
    saveInBackground(context, () => AppointmentRepository.instance.delete(id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final old = _old;
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(old == null ? t.newAppointment : t.appointment)),
          if (old != null && _canEdit)
            IconButton(
              tooltip: t.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateField(
                label: t.date,
                value: _date,
                enabled: _canEdit,
                lastDate: Appointment.lastBookable(DateTime.now()),
                onChanged: (d) => setState(() => _date = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _text,
                enabled: _canEdit,
                autofocus: old == null,
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
                decoration: InputDecoration(
                  labelText: t.appointmentText,
                  hintText: t.appointmentHint,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? t.required : null,
              ),
              if (old != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_authorNote(t))),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_canEdit ? t.cancel : t.close),
        ),
        if (_canEdit) TextButton(onPressed: _save, child: Text(t.save)),
      ],
    );
  }

  String _authorNote(AppLocalizations t) => _canEdit
      ? t.enteredBy(widget.authorName)
      : t.readOnlyNotice(widget.authorName);
}

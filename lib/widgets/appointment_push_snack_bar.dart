import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/appointment_push.dart';

/// What a calendar push says while the app is open, when Android shows
/// nothing by itself.
SnackBar appointmentPushSnackBar(AppLocalizations t, AppointmentPush push) {
  final title = push.isReminder
      ? t.appointmentReminderTitle(push.dateLabel)
      : t.appointmentPushTitle(push.dateLabel);
  return SnackBar(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        // A reminder may list a whole day; the calendar has the rest.
        Text(push.body, maxLines: 4, overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

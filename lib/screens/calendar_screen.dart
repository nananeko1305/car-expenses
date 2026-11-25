import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/app_user.dart';
import '../models/appointment.dart';
import '../models/report.dart';
import '../services/live_data.dart';
import '../theme/app_colors.dart';
import '../widgets/appointment_dialog.dart';
import '../widgets/month_grid.dart';
import '../widgets/month_switcher.dart';
import '../widgets/skewed.dart';
import '../widgets/slant_header.dart';
import '../widgets/sync_banner.dart';

/// The workshop's calendar: a month at a time, and what is booked for the
/// chosen day. Everyone sees every booking. Stays live while open.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _today = DateUtils.dateOnly(DateTime.now());
  late DateTime _selected = _today;

  /// Another month opens on its first day, or on today in this one.
  void _showMonth(DateTime month) {
    setState(() => _selected = inMonth(_today, month) ? _today : month);
  }

  void _open([Appointment? appointment]) {
    showAppointmentDialog(
      context,
      profile: widget.profile,
      day: _selected,
      appointment: appointment,
      authorName: appointment == null
          ? ''
          : widget.data.nameOf(appointment.ownerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: SlantAppBar(title: t.calendar),
      floatingActionButton: SkewFab(
        onPressed: _open,
        icon: Icons.add_rounded,
        label: t.book,
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.data,
              builder: (context, _) => _body(t),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations t) {
    // Not part of LiveData.ready: null is "not here yet", and a failed
    // listener says so instead of spinning forever.
    final all = widget.data.appointments;
    if (all == null) {
      final error = widget.data.error;
      if (error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Text(errorText(t, error), textAlign: TextAlign.center),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    final days = Appointment.byDay(all);
    var first = monthOf(_today);
    for (final day in days.keys) {
      if (day.isBefore(first)) first = monthOf(day);
    }
    final month = monthOf(_selected);
    final booked = days[_selected] ?? const <Appointment>[];
    final locale = Localizations.localeOf(context).toLanguageTag();

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: MonthSwitcher(
            month: month,
            first: first,
            last: monthOf(Appointment.lastBookable(_today)),
            onChanged: _showMonth,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: MonthGrid(
            month: month,
            selected: _selected,
            today: _today,
            counts: {for (final e in days.entries) e.key: e.value.length},
            onSelect: (day) => setState(() => _selected = day),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colors.line)),
          ),
          child: Text(
            DateFormat.MMMMEEEEd(locale).format(_selected).toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (booked.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Text(t.noAppointments, textAlign: TextAlign.center),
          ),
        for (final a in booked)
          _AppointmentCard(
            appointment: a,
            authorName: widget.data.nameOf(a.ownerId),
            onTap: () => _open(a),
          ),
      ],
    );
  }
}

/// One booking as a row: its text, and who wrote it.
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.authorName,
    required this.onTap,
  });

  final Appointment appointment;
  final String authorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.line)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 14, color: c.muted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    authorName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: c.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

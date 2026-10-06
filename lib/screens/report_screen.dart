import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/report.dart';
import '../services/live_data.dart';
import '../widgets/month_switcher.dart';
import '../widgets/report_view.dart';
import '../widgets/sync_banner.dart';

/// The workshop's report, one month at a time or over all time: what it
/// earned, how many cars and services it had, and where the money went.
/// Stays live while open.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.data});

  final LiveData data;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _allTime = false;
  DateTime _month = monthOf(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.monthlyReport)),
      body: Column(
        children: [
          const SyncBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(t.reportByMonth)),
                ButtonSegment(value: true, label: Text(t.reportAllTime)),
              ],
              selected: {_allTime},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _allTime = s.first),
            ),
          ),
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
    final data = widget.data;
    // Tools are not part of LiveData.ready, but the tool spending is in
    // the costs, so the report waits for them too.
    final tools = data.tools;
    if (!data.ready || tools == null) {
      final error = data.error;
      if (error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Text(errorText(t, error), textAlign: TextAlign.center),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    final repairs = data.repairs!;
    final entries = data.entries!;
    final span = Report.span(
      now: DateTime.now(),
      repairs: repairs,
      entries: entries,
      tools: tools,
    );
    final report = Report.of(
      month: _allTime ? null : _month,
      repairs: repairs,
      entries: entries,
      tools: tools,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        if (!_allTime)
          MonthSwitcher(
            month: _month,
            first: span.first,
            last: span.last,
            onChanged: (m) => setState(() => _month = m),
          ),
        const SizedBox(height: 8),
        ReportView(report: report),
      ],
    );
  }
}

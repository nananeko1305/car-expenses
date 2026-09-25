import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/tool.dart';
import '../services/live_data.dart';
import '../widgets/sync_banner.dart';
import '../widgets/tool_card.dart';
import 'tool_form_screen.dart';

/// Shared list of tools, in use or archived. Tools are normally created
/// while spending from the wallet; the button here is for one bought
/// outside it.
class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key, required this.data, required this.profile});

  final LiveData data;
  final AppUser profile;

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  bool _archived = false;

  void _openForm([Tool? tool]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ToolFormScreen(
          data: widget.data,
          profile: widget.profile,
          tool: tool,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // One instant for the whole list, so every bar agrees.
    final now = DateUtils.dateOnly(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(t.tools)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_rounded),
        label: Text(t.addTool),
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(t.activeTools)),
                ButtonSegment(value: true, label: Text(t.archivedTools)),
              ],
              selected: {_archived},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _archived = s.first),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.data,
              builder: (context, _) => _list(t, now),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(AppLocalizations t, DateTime now) {
    // Tools are not part of LiveData.ready, so this screen owns its own
    // loading state: null is "not here yet", empty is "there are none".
    final all = widget.data.tools;
    if (all == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final tools = all.where((x) => x.archived == _archived).toList();
    if (tools.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Text(t.noTools, textAlign: TextAlign.center),
            if (!_archived) ...[
              const SizedBox(height: 8),
              Text(t.noToolsHint, textAlign: TextAlign.center),
            ],
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: tools.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final tool = tools[i];
        // The wallet is the live source for the price; the copy on the
        // tool only has to survive the entry being deleted.
        final entry = widget.data.entryById(tool.entryId);
        return ToolCard(
          tool: tool,
          now: now,
          amountMinor: entry?.amountMinor ?? tool.amountMinor,
          currency: entry?.currency ?? tool.currency,
          onTap: () => _openForm(tool),
        );
      },
    );
  }
}

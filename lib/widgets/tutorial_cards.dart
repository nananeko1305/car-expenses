import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/tutorial_entry.dart';
import '../theme/app_colors.dart';
import 'race_row.dart';
import 'skewed.dart';

/// A make or a model as a row of a list: its name, what it holds, and a
/// chevron.
class TutorialTile extends StatelessWidget {
  const TutorialTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => RaceRow(
    leading: SkewIcon(icon),
    title: title,
    subtitle: subtitle,
    trailing: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(Icons.chevron_right_rounded, color: context.colors.muted),
    ),
    onTap: onTap,
  );
}

/// One link as a row: tapping opens it, the pencil edits it.
class TutorialLinkCard extends StatelessWidget {
  const TutorialLinkCard({
    super.key,
    required this.link,
    required this.onOpen,
    required this.onEdit,
  });

  final TutorialLink link;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return RaceRow(
      leading: SkewIcon(
        link.isVideo ? Icons.play_arrow_rounded : Icons.link_rounded,
        color: context.colors.accentText,
      ),
      title: link.label,
      titleMaxLines: 2,
      subtitle: link.host,
      trailing: IconButton(
        tooltip: t.edit,
        icon: const Icon(Icons.edit_rounded),
        onPressed: onEdit,
      ),
      onTap: onOpen,
    );
  }
}

/// One note as a row: which year and engine it is about, its text, then
/// who wrote it and when. Tapping edits it.
class TutorialNoteCard extends StatelessWidget {
  const TutorialNoteCard({
    super.key,
    required this.note,
    required this.authorName,
    required this.onTap,
  });

  final TutorialNote note;
  final String authorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale)
        .format(note.createdAt ?? DateTime.now());
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
            if (note.details.isNotEmpty) ...[
              Text(
                note.details,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: c.accentText,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(note.text, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 6),
            Text(
              '$authorName · $date',
              style: TextStyle(fontSize: 13, color: c.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list's heading, such as "Links" or "Notes", in leaning capitals.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.inset = 16});

  final String text;

  /// The space at its sides: none inside a form, which has its own.
  final double inset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(inset, 18, inset, 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

/// What a screen shows while its collections are not here yet: the
/// error, when a listener failed, or a spinner.
class TutorialsLoading extends StatelessWidget {
  const TutorialsLoading({super.key, required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error == null) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Text(
        errorText(AppLocalizations.of(context), error),
        textAlign: TextAlign.center,
      ),
    );
  }
}

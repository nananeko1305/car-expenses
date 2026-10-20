import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_text.dart';
import '../models/tutorial_entry.dart';
import '../theme/app_colors.dart';

/// A make or a model in a list: its name, what it holds, and a chevron.
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
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: context.colors.soft,
          foregroundColor: context.colors.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

/// One link: tapping opens it, the pencil edits it.
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onOpen,
        contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        leading: CircleAvatar(
          backgroundColor: context.colors.soft,
          foregroundColor: context.colors.primary,
          child: Icon(
            link.isVideo ? Icons.play_arrow_rounded : Icons.link_rounded,
          ),
        ),
        title: Text(
          link.label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(link.host, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          tooltip: t.edit,
          icon: const Icon(Icons.edit_rounded),
          onPressed: onEdit,
        ),
      ),
    );
  }
}

/// One note: its text, then who wrote it and when. Tapping edits it.
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale)
        .format(note.createdAt ?? DateTime.now());
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.text, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              Text(
                '$authorName · $date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.ink.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A list's heading, such as "Links" or "Notes".
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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

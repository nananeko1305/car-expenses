import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial_entry.dart';

/// The editable title and address of one link, shared by the new-model
/// form (several of them) and the link dialog (one).
class LinkDraft {
  LinkDraft([TutorialLink? link])
    : title = TextEditingController(text: link?.title ?? ''),
      url = TextEditingController(text: link?.url ?? '');

  final TextEditingController title;
  final TextEditingController url;

  /// Nothing typed in either field: a row the form may skip.
  bool get isEmpty => title.text.trim().isEmpty && url.text.trim().isEmpty;

  void dispose() {
    title.dispose();
    url.dispose();
  }
}

/// Title and address fields for a [LinkDraft]. The address is checked
/// with [normalizeUrl]; it may be left out only when [optional] and the
/// title is empty too, so a blank row in the form passes.
class LinkFields extends StatelessWidget {
  const LinkFields({super.key, required this.draft, this.optional = false});

  final LinkDraft draft;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        TextFormField(
          controller: draft.title,
          maxLength: 100,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: t.linkTitle,
            hintText: t.linkTitleHint,
            counterText: '',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: draft.url,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: t.linkUrl,
            hintText: 'youtube.com/…',
            prefixIcon: const Icon(Icons.link_rounded),
          ),
          validator: (v) {
            final text = v?.trim() ?? '';
            if (text.isEmpty) {
              return optional && draft.title.text.trim().isEmpty
                  ? null
                  : t.required;
            }
            return normalizeUrl(text) == null ? t.invalidUrl : null;
          },
        ),
      ],
    );
  }
}

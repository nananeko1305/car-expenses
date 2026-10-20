import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/tutorial.dart';
import '../models/tutorial_entry.dart';
import '../services/background_save.dart';
import '../services/tutorial_repository.dart';
import '../widgets/link_fields.dart';
import '../widgets/tutorial_cards.dart';

/// A new model of [brand], with its first links: one row to start with,
/// and a button for more. Blank rows are skipped, and a name in [taken]
/// (the make's other models) is refused.
class TutorialModelFormScreen extends StatefulWidget {
  const TutorialModelFormScreen({
    super.key,
    required this.profile,
    required this.brand,
    required this.taken,
  });

  final AppUser profile;
  final TutorialBrand brand;
  final Iterable<String> taken;

  @override
  State<TutorialModelFormScreen> createState() =>
      _TutorialModelFormScreenState();
}

class _TutorialModelFormScreenState extends State<TutorialModelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final List<LinkDraft> _links = [LinkDraft()];

  @override
  void dispose() {
    _name.dispose();
    for (final l in _links) {
      l.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _links.add(LinkDraft()));

  void _removeRow(LinkDraft row) {
    setState(() => _links.remove(row));
    // Its fields are still on screen until this frame is drawn.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final uid = widget.profile.uid;
    final model = TutorialModel(
      id: '',
      ownerId: uid,
      brandId: widget.brand.id,
      name: _name.text.trim(),
    );
    final links = [
      for (final row in _links)
        if (!row.isEmpty)
          TutorialLink(
            id: '',
            ownerId: uid,
            modelId: '',
            title: row.title.text.trim(),
            url: normalizeUrl(row.url.text)!,
          ),
    ];
    saveInBackground(
      context,
      () => TutorialRepository.instance.createModel(model, links),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${widget.brand.name} · ${t.newModel}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: t.modelName,
                hintText: t.modelHint,
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return t.required;
                return nameTaken(v, widget.taken) ? t.modelExists : null;
              },
            ),
            SectionTitle(t.links),
            for (final row in _links) ...[
              Card(
                key: ObjectKey(row),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                  child: Column(
                    children: [
                      if (_links.length > 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            tooltip: t.removeLink,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => _removeRow(row),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: LinkFields(draft: row, optional: true),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add_rounded),
                label: Text(t.addAnotherLink),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(t.save)),
          ],
        ),
      ),
    );
  }
}

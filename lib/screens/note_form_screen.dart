import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/app_user.dart';
import '../models/tutorial.dart';
import '../services/background_save.dart';
import '../services/tutorial_repository.dart';
import '../widgets/name_autocomplete_field.dart';
import '../widgets/note_fields.dart';

/// A new note on a make and model typed by name, suggested from [brands]
/// and [models]. One that is not among them is created with the note.
class NoteFormScreen extends StatefulWidget {
  const NoteFormScreen({
    super.key,
    required this.profile,
    required this.brands,
    required this.models,
  });

  final AppUser profile;
  final List<TutorialBrand> brands;
  final List<TutorialModel> models;

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _draft = NoteDraft();

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _draft.dispose();
    super.dispose();
  }

  TutorialBrand? get _typedBrand =>
      findByName(widget.brands, _brand.text, (b) => b.name);

  Iterable<TutorialModel> _modelsOf(TutorialBrand? brand) =>
      widget.models.where((m) => m.brandId == brand?.id);

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final brand = _typedBrand;
    final model = findByName(_modelsOf(brand), _model.text, (m) => m.name);
    final note = _draft.toNote(
      id: '',
      ownerId: widget.profile.uid,
      modelId: model?.id ?? '',
    );
    final brandName = _brand.text.trim();
    final modelName = _model.text.trim();
    saveInBackground(
      context,
      () => TutorialRepository.instance.createNoteFor(
        note,
        brandName: brandName,
        modelName: modelName,
        brand: brand,
        model: model,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.newNote)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            NameAutocompleteField(
              controller: _brand,
              autofocus: true,
              label: t.brandName,
              hint: t.brandHint,
              suggestions: [
                for (final b in sortedByName(widget.brands, (b) => b.name))
                  b.name,
              ],
            ),
            const SizedBox(height: 10),
            ListenableBuilder(
              listenable: _brand,
              builder: (context, _) {
                final brand = _typedBrand;
                return NameAutocompleteField(
                  // Suggestions are worked out when the text changes, so
                  // another make needs a fresh field to offer its models.
                  key: ValueKey(brand?.id),
                  controller: _model,
                  label: t.modelName,
                  hint: t.modelHint,
                  suggestions: [
                    for (final m in sortedByName(
                      _modelsOf(brand),
                      (m) => m.name,
                    ))
                      m.name,
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            NoteFields(draft: _draft),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(t.save)),
          ],
        ),
      ),
    );
  }
}

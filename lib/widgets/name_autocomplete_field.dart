import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/tutorial.dart';

/// Required name field that suggests [suggestions] while typing, going by
/// [foldLetters], but takes any other name too.
class NameAutocompleteField extends StatefulWidget {
  const NameAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestions,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final List<String> suggestions;
  final bool autofocus;

  @override
  State<NameAutocompleteField> createState() => _NameAutocompleteFieldState();
}

class _NameAutocompleteFieldState extends State<NameAutocompleteField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // RawAutocomplete works out suggestions only when the field changes.
    // Focus gives a cursor to a field without one, which counts, so a
    // fresh field offers them on its first tap even if its text is old.
    widget.controller.selection = const TextSelection.collapsed(offset: -1);
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: (value) {
        final typed = foldLetters(value.text.trim());
        return widget.suggestions.where((s) {
          final name = foldLetters(s);
          return name.contains(typed) && name != typed;
        });
      },
      // Not wired to onFieldSubmitted: the keyboard's "next" would swap
      // a new name for the first suggestion.
      fieldViewBuilder: (context, controller, focusNode, _) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            counterText: '',
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? t.required : null,
        );
      },
      optionsViewBuilder: (context, onSelect, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final name in options)
                    ListTile(
                      title: Text(name, overflow: TextOverflow.ellipsis),
                      onTap: () => onSelect(name),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

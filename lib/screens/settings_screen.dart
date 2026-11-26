import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/background_save.dart';
import '../services/user_repository.dart';
import '../theme/app_palette.dart';
import '../theme/theme_controller.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/name_fields.dart';
import '../widgets/skewed.dart';
import '../widgets/slant_header.dart';
import '../widgets/theme_mode_picker.dart';
import '../widgets/update_tiles.dart';
import '../services/ui_choice.dart';
import '../widgets/ui_style_picker.dart';

/// Profile (name, password) plus language, color and light or dark
/// (or whichever the phone is in). The look-and-feel settings are stored
/// on the device only.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        final code = localeController.locale?.languageCode;
        return Scaffold(
          appBar: SlantAppBar(title: t.settings),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(t.profile),
              _profileTiles(context, t),
              const SizedBox(height: 16),
              _header(t.language),
              RadioGroup<String?>(
                groupValue: code,
                onChanged: (c) =>
                    localeController.select(c == null ? null : Locale(c)),
                child: Column(
                  children: [
                    RadioListTile<String?>(
                      value: null,
                      title: Text(t.systemLanguage),
                    ),
                    const RadioListTile<String?>(
                      value: 'en',
                      title: Text('English'),
                    ),
                    const RadioListTile<String?>(
                      value: 'sr',
                      title: Text('Srpski'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _header(t.theme),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [for (final p in kPalettes) _swatch(t, p)],
              ),
              const SizedBox(height: 16),
              _header(t.themeMode),
              ThemeModePicker(
                value: themeController.mode,
                onChanged: themeController.setMode,
              ),
              const SizedBox(height: 16),
              _header(t.uiStyle),
              UiStylePicker(
                value: uiChoice.style,
                onChanged: (style) {
                  // The whole app is drawn again in the other interface,
                  // so this screen cannot stay open over it.
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  uiChoice.set(style);
                },
              ),
              const SizedBox(height: 16),
              const UpdateTiles(),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text(t.signOut),
                onTap: () {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                  AuthService.instance.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Name and email come from the live profile, so a rename shows at once.
  Widget _profileTiles(BuildContext context, AppLocalizations t) {
    return StreamBuilder<AppUser?>(
      stream: UserRepository.instance.watchProfile(profile.uid),
      initialData: profile,
      builder: (context, snap) {
        final me = snap.data ?? profile;
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.badge_rounded),
              title: Text(me.displayName),
              subtitle: Text(me.email),
              trailing: const Icon(Icons.edit_rounded),
              onTap: () => showEditNameDialog(
                context,
                firstName: me.firstName,
                lastName: me.lastName,
                onSave: (first, last) => saveInBackground(
                  context,
                  () => UserRepository.instance.updateName(me.uid, first, last),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset_rounded),
              title: Text(t.changePassword),
              onTap: () => showChangePasswordDialog(context),
            ),
          ],
        );
      },
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _swatch(AppLocalizations t, AppPalette p) {
    final selected = themeController.current.id == p.id;
    return Tooltip(
      message: _paletteName(t, p),
      child: Skewed(
        child: Material(
          color: p.primary,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => themeController.select(p),
            child: SizedBox(
              width: 48,
              height: 48,
              child: selected
                  ? Icon(Icons.check_rounded, color: p.onPrimary)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  /// The palette's own [AppPalette.label] is an English fallback; the
  /// settings screen shows the name in the app language.
  String _paletteName(AppLocalizations t, AppPalette p) => switch (p.id) {
    'plava' => t.colorBlue,
    'topla' => t.colorWarm,
    'crvena' => t.colorRed,
    'zelena' => t.colorGreen,
    'zuta' => t.colorYellow,
    'ljubicasta' => t.colorPurple,
    _ => p.label,
  };
}

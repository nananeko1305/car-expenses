import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'screens/auth_gate.dart';
import 'services/euro_visibility.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await themeController.load();
  await localeController.load();
  await euroVisibility.load();
  runApp(const CarExpensesApp());
}

/// Serbian as the app writes it: in Latin script. Plain `sr` would have
/// the dates and the system's own texts (the date picker, tooltips) come
/// out in Cyrillic next to the app's Latin.
const _serbianLatin = Locale.fromSubtags(
  languageCode: 'sr',
  scriptCode: 'Latn',
);
const _supported = AppLocalizations.supportedLocales;

/// [locale] as the app runs it: any Serbian becomes [_serbianLatin], a
/// supported language stays, and anything else (or none) is null.
Locale? _latin(Locale? locale) => switch (locale?.languageCode) {
  'sr' => _serbianLatin,
  final code? when _supported.any((l) => l.languageCode == code) => Locale(
    code,
  ),
  _ => null,
};

class CarExpensesApp extends StatelessWidget {
  const CarExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when the theme or the language changes.
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,
          locale: _latin(localeController.locale),
          localeResolutionCallback: (phone, _) =>
              _latin(phone) ?? const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [..._supported, _serbianLatin],
          // Screens without an AppBar (login, admin claim, notices) get the
          // right status-bar icon color from here. The theme in effect says
          // whether it is dark, since the mode may leave that to the phone.
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.overlayStyle(
              Theme.of(context).brightness == Brightness.dark,
            ),
            child: child!,
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}

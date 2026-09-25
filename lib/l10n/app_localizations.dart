import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Car Expenses'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Every service and every dinar, in one place'**
  String get appTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the account the admin created for you.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @minChars6.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get minChars6;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get wait;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetSent;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email is not valid.'**
  String get errInvalidEmail;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (min. 6 characters).'**
  String get errWeakPassword;

  /// No description provided for @errWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errWrongCredentials;

  /// No description provided for @errUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled.'**
  String get errUserDisabled;

  /// No description provided for @errNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errNoNetwork;

  /// No description provided for @errPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action.'**
  String get errPermission;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Finishing setup'**
  String get setupTitle;

  /// No description provided for @claimAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Become the admin'**
  String get claimAdminTitle;

  /// No description provided for @claimAdminBody.
  ///
  /// In en, this message translates to:
  /// **'No admin exists yet. Enter your name; your account will become the admin and will be able to add other users.'**
  String get claimAdminBody;

  /// No description provided for @claimAdmin.
  ///
  /// In en, this message translates to:
  /// **'Become admin'**
  String get claimAdmin;

  /// No description provided for @noAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get noAccessTitle;

  /// No description provided for @noAccessBody.
  ///
  /// In en, this message translates to:
  /// **'This account is not registered in the app. Ask the admin to add you.'**
  String get noAccessBody;

  /// No description provided for @disabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Account disabled'**
  String get disabledTitle;

  /// No description provided for @disabledBody.
  ///
  /// In en, this message translates to:
  /// **'The admin has disabled this account.'**
  String get disabledBody;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @repairs.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get repairs;

  /// No description provided for @noRepairs.
  ///
  /// In en, this message translates to:
  /// **'No services yet.\nTap + to add the first one.'**
  String get noRepairs;

  /// No description provided for @noVehiclesYet.
  ///
  /// In en, this message translates to:
  /// **'Add a car before adding services.'**
  String get noVehiclesYet;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get addVehicle;

  /// No description provided for @allVehicles.
  ///
  /// In en, this message translates to:
  /// **'All cars'**
  String get allVehicles;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @repairsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 service} other{{count} services}}'**
  String repairsCount(int count);

  /// No description provided for @newRepair.
  ///
  /// In en, this message translates to:
  /// **'New service'**
  String get newRepair;

  /// No description provided for @editRepair.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get editRepair;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicle;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @mileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage (km)'**
  String get mileage;

  /// No description provided for @mileageOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get mileageOptional;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What was done, parts...'**
  String get descriptionHint;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get invalidAmount;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get invalidNumber;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteRepairQ.
  ///
  /// In en, this message translates to:
  /// **'Delete this service?'**
  String get deleteRepairQ;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get vehicles;

  /// No description provided for @noVehicles.
  ///
  /// In en, this message translates to:
  /// **'No cars yet.'**
  String get noVehicles;

  /// No description provided for @newVehicle.
  ///
  /// In en, this message translates to:
  /// **'New car'**
  String get newVehicle;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get editVehicle;

  /// No description provided for @vehicleName.
  ///
  /// In en, this message translates to:
  /// **'Make and model'**
  String get vehicleName;

  /// No description provided for @vehicleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Škoda Octavia'**
  String get vehicleNameHint;

  /// No description provided for @plate.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get plate;

  /// No description provided for @plateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. BG-123-AB'**
  String get plateHint;

  /// No description provided for @deleteVehicleQ.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteVehicleQ(String name);

  /// No description provided for @deleteVehicleBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteVehicleBody;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// No description provided for @newUserPassword.
  ///
  /// In en, this message translates to:
  /// **'Initial password'**
  String get newUserPassword;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User {email} created'**
  String userCreated(String email);

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get you;

  /// No description provided for @disableUser.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disableUser;

  /// No description provided for @enableUser.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableUser;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get systemLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorWarm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get colorWarm;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @vehicleHasServices.
  ///
  /// In en, this message translates to:
  /// **'This car has services, so it can\'t be deleted.'**
  String get vehicleHasServices;

  /// No description provided for @addToWallet.
  ///
  /// In en, this message translates to:
  /// **'Add amount to wallet'**
  String get addToWallet;

  /// No description provided for @addToWalletHint.
  ///
  /// In en, this message translates to:
  /// **'The service amount goes into the shared wallet.'**
  String get addToWalletHint;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @allPeople.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get allPeople;

  /// No description provided for @enteredBy.
  ///
  /// In en, this message translates to:
  /// **'Entered by {name}'**
  String enteredBy(String name);

  /// No description provided for @readOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Only {name} or the admin can change this.'**
  String readOnlyNotice(String name);

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @addFunds.
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get addFunds;

  /// No description provided for @spendFunds.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get spendFunds;

  /// No description provided for @newDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get newDeposit;

  /// No description provided for @newWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Spend from wallet'**
  String get newWithdrawal;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @spentOn.
  ///
  /// In en, this message translates to:
  /// **'What was it spent on'**
  String get spentOn;

  /// No description provided for @depositNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get depositNote;

  /// No description provided for @depositNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. cash from the office'**
  String get depositNoteHint;

  /// No description provided for @spentBy.
  ///
  /// In en, this message translates to:
  /// **'Spent by'**
  String get spentBy;

  /// No description provided for @addedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by'**
  String get addedBy;

  /// No description provided for @serviceIncome.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get serviceIncome;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get withdrawal;

  /// No description provided for @noMovements.
  ///
  /// In en, this message translates to:
  /// **'No wallet movements yet.'**
  String get noMovements;

  /// No description provided for @deleteEntryQ.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteEntryQ;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPassword;

  /// No description provided for @passwordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNoMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordChanged;

  /// No description provided for @searchPlate.
  ///
  /// In en, this message translates to:
  /// **'Search by plate'**
  String get searchPlate;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'License plate or car'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No cars found.'**
  String get noResults;

  /// No description provided for @serviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Service history'**
  String get serviceHistory;

  /// No description provided for @lastMileage.
  ///
  /// In en, this message translates to:
  /// **'Last mileage'**
  String get lastMileage;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @noServicesForCar.
  ///
  /// In en, this message translates to:
  /// **'No services for this car yet.'**
  String get noServicesForCar;

  /// No description provided for @newVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get newVersionTitle;

  /// No description provided for @newVersionBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build}) is ready to download. You have build {current}.'**
  String newVersionBody(String version, int build, int current);

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version.'**
  String get upToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates.'**
  String get updateCheckFailed;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build})'**
  String appVersion(String version, String build);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

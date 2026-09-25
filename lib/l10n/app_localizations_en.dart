// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Car Expenses';

  @override
  String get appTagline => 'Every service and every dinar, in one place';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'Use the account the admin created for you.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get minChars6 => 'At least 6 characters';

  @override
  String get signIn => 'Sign in';

  @override
  String get wait => 'Please wait...';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetSent => 'Password reset email sent.';

  @override
  String get errInvalidEmail => 'The email is not valid.';

  @override
  String get errEmailInUse => 'An account with this email already exists.';

  @override
  String get errWeakPassword => 'Password is too weak (min. 6 characters).';

  @override
  String get errWrongCredentials => 'Wrong email or password.';

  @override
  String get errUserDisabled => 'This account is disabled.';

  @override
  String get errNoNetwork => 'No internet connection.';

  @override
  String get errPermission => 'You don\'t have permission for this action.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get setupTitle => 'Finishing setup';

  @override
  String get claimAdminTitle => 'Become the admin';

  @override
  String get claimAdminBody =>
      'No admin exists yet. Enter your name; your account will become the admin and will be able to add other users.';

  @override
  String get claimAdmin => 'Become admin';

  @override
  String get noAccessTitle => 'No access';

  @override
  String get noAccessBody =>
      'This account is not registered in the app. Ask the admin to add you.';

  @override
  String get disabledTitle => 'Account disabled';

  @override
  String get disabledBody => 'The admin has disabled this account.';

  @override
  String get signOut => 'Sign out';

  @override
  String get repairs => 'Services';

  @override
  String get noRepairs => 'No services yet.\nTap + to add the first one.';

  @override
  String get noVehiclesYet => 'Add a car before adding services.';

  @override
  String get addVehicle => 'Add car';

  @override
  String get allVehicles => 'All cars';

  @override
  String get total => 'Total';

  @override
  String repairsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '1 service',
    );
    return '$_temp0';
  }

  @override
  String get newRepair => 'New service';

  @override
  String get editRepair => 'Edit service';

  @override
  String get vehicle => 'Car';

  @override
  String get date => 'Date';

  @override
  String get amount => 'Amount';

  @override
  String get currency => 'Currency';

  @override
  String get mileage => 'Mileage (km)';

  @override
  String get mileageOptional => 'Optional';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'What was done, parts...';

  @override
  String get required => 'Required';

  @override
  String get invalidAmount => 'Enter an amount greater than 0';

  @override
  String get invalidNumber => 'Enter a whole number';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteRepairQ => 'Delete this service?';

  @override
  String get deleted => 'Deleted';

  @override
  String get saved => 'Saved';

  @override
  String get vehicles => 'Cars';

  @override
  String get noVehicles => 'No cars yet.';

  @override
  String get newVehicle => 'New car';

  @override
  String get editVehicle => 'Edit car';

  @override
  String get vehicleName => 'Make and model';

  @override
  String get vehicleNameHint => 'e.g. Škoda Octavia';

  @override
  String get plate => 'License plate';

  @override
  String get plateHint => 'e.g. BG-123-AB';

  @override
  String deleteVehicleQ(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteVehicleBody => 'This can\'t be undone.';

  @override
  String get users => 'Users';

  @override
  String get addUser => 'Add user';

  @override
  String get newUserPassword => 'Initial password';

  @override
  String userCreated(String email) {
    return 'User $email created';
  }

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleUser => 'User';

  @override
  String get disabled => 'Disabled';

  @override
  String get you => 'you';

  @override
  String get disableUser => 'Disable';

  @override
  String get enableUser => 'Enable';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'Phone language';

  @override
  String get theme => 'Color';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorWarm => 'Warm';

  @override
  String get colorRed => 'Red';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorPurple => 'Purple';

  @override
  String get syncing => 'Syncing...';

  @override
  String get synced => 'Synced';

  @override
  String get vehicleHasServices =>
      'This car has services, so it can\'t be deleted.';

  @override
  String get addToWallet => 'Add amount to wallet';

  @override
  String get addToWalletHint =>
      'The service amount goes into the shared wallet.';

  @override
  String get person => 'Person';

  @override
  String get allPeople => 'Everyone';

  @override
  String enteredBy(String name) {
    return 'Entered by $name';
  }

  @override
  String readOnlyNotice(String name) {
    return 'Only $name or the admin can change this.';
  }

  @override
  String get wallet => 'Wallet';

  @override
  String get balance => 'Balance';

  @override
  String get addFunds => 'Add funds';

  @override
  String get spendFunds => 'Spend';

  @override
  String get newDeposit => 'Add funds';

  @override
  String get newWithdrawal => 'Spend from wallet';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get spentOn => 'What was it spent on';

  @override
  String get depositNote => 'Note';

  @override
  String get depositNoteHint => 'e.g. cash from the office';

  @override
  String get spentBy => 'Spent by';

  @override
  String get addedBy => 'Added by';

  @override
  String get serviceIncome => 'Service';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdrawal => 'Spending';

  @override
  String get noMovements => 'No wallet movements yet.';

  @override
  String get deleteEntryQ => 'Delete this entry?';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get profile => 'Profile';

  @override
  String get editName => 'Edit name';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get passwordsNoMatch => 'Passwords do not match';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get searchPlate => 'Search by plate';

  @override
  String get searchHint => 'License plate or car';

  @override
  String get noResults => 'No cars found.';

  @override
  String get serviceHistory => 'Service history';

  @override
  String get lastMileage => 'Last mileage';

  @override
  String get edit => 'Edit';

  @override
  String get noServicesForCar => 'No services for this car yet.';

  @override
  String get newVersionTitle => 'New version available';

  @override
  String newVersionBody(String version, String current) {
    return 'Version $version is ready to download. You have $current.';
  }

  @override
  String get download => 'Download';

  @override
  String get later => 'Later';

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get upToDate => 'You have the latest version.';

  @override
  String get updateCheckFailed => 'Couldn\'t check for updates.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get tools => 'Tools';

  @override
  String get noTools => 'No tools yet.';

  @override
  String get noToolsHint =>
      'A tool is usually added while spending from the wallet, or with the button below.';

  @override
  String get addTool => 'Add tool';

  @override
  String get newTool => 'New tool';

  @override
  String get editTool => 'Edit tool';

  @override
  String get toolName => 'Tool';

  @override
  String get toolNameHint => 'e.g. impact driver';

  @override
  String get addToTools => 'Add to tools';

  @override
  String get addToToolsHint => 'Everything that is not consumable is a tool.';

  @override
  String get warranty => 'Warranty';

  @override
  String get warrantyMonths => 'Months';

  @override
  String get warrantyYears => 'Years';

  @override
  String get warrantyMonthsRange => '1 to 12 months, longer ones in years';

  @override
  String get warrantyYearsMin => 'At least 1 year';

  @override
  String warrantyUntil(String date) {
    return 'Warranty until $date';
  }

  @override
  String warrantyDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get warrantyEndsToday => 'Warranty ends today';

  @override
  String get warrantyExpired => 'Warranty expired';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get purchaseDateHint =>
      'The date on the receipt; the warranty starts then.';

  @override
  String get notifyOnExpiry => 'Remind before it expires';

  @override
  String get notifyOnExpiryHint => '30 days before, and the day before.';

  @override
  String get toolPriceOptional => 'Optional, when there is no wallet entry';

  @override
  String get openWalletEntry => 'Open the spending in the wallet';

  @override
  String get activeTools => 'In use';

  @override
  String get archivedTools => 'Archived';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Restore';

  @override
  String archiveToolQ(String name) {
    return 'Archive $name?';
  }

  @override
  String get archiveToolBody =>
      'It leaves the list. The spending stays in the wallet.';

  @override
  String get entryHasTool =>
      'This spending bought a tool, so it can\'t be deleted.';

  @override
  String get receipt => 'Receipt';

  @override
  String get addReceipt => 'Add the receipt';

  @override
  String get receiptHint =>
      'A photo, so you have it when you claim the warranty.';

  @override
  String get receiptUploading => 'Sending the photo...';

  @override
  String get receiptCamera => 'Take a photo';

  @override
  String get receiptGallery => 'Pick from the gallery';
}

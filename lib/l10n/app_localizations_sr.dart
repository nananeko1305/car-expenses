// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Troškovi automobila';

  @override
  String get appTagline => 'Svaki servis i svaki dinar, na jednom mestu';

  @override
  String get loginTitle => 'Prijava';

  @override
  String get loginSubtitle => 'Koristi nalog koji ti je napravio admin.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Lozinka';

  @override
  String get invalidEmail => 'Unesi ispravan email';

  @override
  String get minChars6 => 'Najmanje 6 karaktera';

  @override
  String get signIn => 'Prijavi se';

  @override
  String get wait => 'Sačekaj...';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get resetSent => 'Poslat je email za promenu lozinke.';

  @override
  String get errInvalidEmail => 'Email nije ispravan.';

  @override
  String get errEmailInUse => 'Nalog sa ovim emailom već postoji.';

  @override
  String get errWeakPassword => 'Lozinka je preslaba (min. 6 karaktera).';

  @override
  String get errWrongCredentials => 'Pogrešan email ili lozinka.';

  @override
  String get errUserDisabled => 'Ovaj nalog je onemogućen.';

  @override
  String get errNoNetwork => 'Nema internet konekcije.';

  @override
  String get errPermission => 'Nemaš dozvolu za ovu akciju.';

  @override
  String get errGeneric => 'Nešto nije u redu. Pokušaj ponovo.';

  @override
  String get setupTitle => 'Završavam podešavanje';

  @override
  String get claimAdminTitle => 'Postani admin';

  @override
  String get claimAdminBody =>
      'Admin još ne postoji. Unesi ime i prezime; tvoj nalog postaje admin i moći će da dodaje druge korisnike.';

  @override
  String get claimAdmin => 'Postani admin';

  @override
  String get noAccessTitle => 'Nema pristupa';

  @override
  String get noAccessBody =>
      'Ovaj nalog nije registrovan u aplikaciji. Zamoli admina da te doda.';

  @override
  String get disabledTitle => 'Nalog onemogućen';

  @override
  String get disabledBody => 'Admin je onemogućio ovaj nalog.';

  @override
  String get signOut => 'Odjavi se';

  @override
  String get repairs => 'Servisi';

  @override
  String get noRepairs => 'Još nema servisa.\nDodirni + da dodaš prvi.';

  @override
  String get noVehiclesYet => 'Dodaj auto pre nego što dodaš servis.';

  @override
  String get addVehicle => 'Dodaj auto';

  @override
  String get allVehicles => 'Svi automobili';

  @override
  String get total => 'Ukupno';

  @override
  String repairsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servisa',
      few: '$count servisa',
      one: '1 servis',
    );
    return '$_temp0';
  }

  @override
  String get newRepair => 'Novi servis';

  @override
  String get editRepair => 'Izmena servisa';

  @override
  String get vehicle => 'Auto';

  @override
  String get date => 'Datum';

  @override
  String get amount => 'Iznos';

  @override
  String get currency => 'Valuta';

  @override
  String get mileage => 'Kilometraža (km)';

  @override
  String get mileageOptional => 'Nije obavezno';

  @override
  String get description => 'Opis';

  @override
  String get descriptionHint => 'Šta je rađeno, delovi...';

  @override
  String get required => 'Obavezno';

  @override
  String get invalidAmount => 'Unesi iznos veći od 0';

  @override
  String get invalidNumber => 'Unesi ceo broj';

  @override
  String get save => 'Sačuvaj';

  @override
  String get saving => 'Čuvam...';

  @override
  String get delete => 'Obriši';

  @override
  String get cancel => 'Otkaži';

  @override
  String get deleteRepairQ => 'Obrisati ovaj servis?';

  @override
  String get deleted => 'Obrisano';

  @override
  String get saved => 'Sačuvano';

  @override
  String get vehicles => 'Automobili';

  @override
  String get noVehicles => 'Još nema automobila.';

  @override
  String get newVehicle => 'Novi auto';

  @override
  String get editVehicle => 'Izmena automobila';

  @override
  String get vehicleName => 'Marka i model';

  @override
  String get vehicleNameHint => 'npr. Škoda Octavia';

  @override
  String get plate => 'Registarska oznaka';

  @override
  String get plateHint => 'npr. BG-123-AB';

  @override
  String deleteVehicleQ(String name) {
    return 'Obrisati $name?';
  }

  @override
  String get deleteVehicleBody => 'Ovo ne može da se poništi.';

  @override
  String get users => 'Korisnici';

  @override
  String get addUser => 'Dodaj korisnika';

  @override
  String get newUserPassword => 'Početna lozinka';

  @override
  String userCreated(String email) {
    return 'Korisnik $email je napravljen';
  }

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleUser => 'Korisnik';

  @override
  String get disabled => 'Onemogućen';

  @override
  String get you => 'ti';

  @override
  String get disableUser => 'Onemogući';

  @override
  String get enableUser => 'Omogući';

  @override
  String get settings => 'Podešavanja';

  @override
  String get language => 'Jezik';

  @override
  String get systemLanguage => 'Jezik telefona';

  @override
  String get theme => 'Boja';

  @override
  String get darkMode => 'Tamni režim';

  @override
  String get syncing => 'Sinhronizujem...';

  @override
  String get synced => 'Sinhronizovano';

  @override
  String get vehicleHasServices =>
      'Ovaj auto ima servise, pa ne može da se obriše.';

  @override
  String get addToWallet => 'Dodaj iznos u wallet';

  @override
  String get addToWalletHint => 'Iznos servisa ulazi u zajednički wallet.';

  @override
  String get person => 'Osoba';

  @override
  String get allPeople => 'Svi';

  @override
  String enteredBy(String name) {
    return 'Uneo/la: $name';
  }

  @override
  String readOnlyNotice(String name) {
    return 'Ovo mogu da menjaju samo $name ili admin.';
  }

  @override
  String get wallet => 'Wallet';

  @override
  String get balance => 'Stanje';

  @override
  String get addFunds => 'Dodaj sredstva';

  @override
  String get spendFunds => 'Potroši';

  @override
  String get newDeposit => 'Dodavanje sredstava';

  @override
  String get newWithdrawal => 'Trošak iz walleta';

  @override
  String get editEntry => 'Izmena stavke';

  @override
  String get spentOn => 'Na šta je potrošeno';

  @override
  String get depositNote => 'Napomena';

  @override
  String get depositNoteHint => 'npr. keš iz kancelarije';

  @override
  String get spentBy => 'Ko je potrošio';

  @override
  String get addedBy => 'Ko je dodao';

  @override
  String get serviceIncome => 'Servis';

  @override
  String get deposit => 'Uplata';

  @override
  String get withdrawal => 'Trošak';

  @override
  String get noMovements => 'Još nema promena u walletu.';

  @override
  String get deleteEntryQ => 'Obrisati ovu stavku?';

  @override
  String get firstName => 'Ime';

  @override
  String get lastName => 'Prezime';

  @override
  String get profile => 'Profil';

  @override
  String get editName => 'Izmeni ime';

  @override
  String get changePassword => 'Promeni lozinku';

  @override
  String get currentPassword => 'Trenutna lozinka';

  @override
  String get newPassword => 'Nova lozinka';

  @override
  String get confirmPassword => 'Potvrdi novu lozinku';

  @override
  String get passwordsNoMatch => 'Lozinke se ne poklapaju';

  @override
  String get passwordChanged => 'Lozinka je promenjena.';

  @override
  String get searchPlate => 'Pretraga po tablicama';

  @override
  String get searchHint => 'Registarska oznaka ili auto';

  @override
  String get noResults => 'Nema pronađenih automobila.';

  @override
  String get serviceHistory => 'Istorija servisa';

  @override
  String get lastMileage => 'Poslednja kilometraža';

  @override
  String get edit => 'Izmeni';

  @override
  String get noServicesForCar => 'Ovaj auto još nema servisa.';

  @override
  String get newVersionTitle => 'Dostupna je nova verzija';

  @override
  String newVersionBody(String version, int build, int current) {
    return 'Verzija $version (build $build) je spremna za preuzimanje. Ti imaš build $current.';
  }

  @override
  String get download => 'Preuzmi';

  @override
  String get later => 'Kasnije';

  @override
  String get checkUpdates => 'Proveri ažuriranja';

  @override
  String get upToDate => 'Imaš najnoviju verziju.';

  @override
  String get updateCheckFailed => 'Provera ažuriranja nije uspela.';

  @override
  String appVersion(String version, String build) {
    return 'Verzija $version (build $build)';
  }
}

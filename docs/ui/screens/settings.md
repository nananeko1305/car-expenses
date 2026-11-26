# Settings

Code: `lib/screens/settings_screen.dart`, `lib/widgets/name_fields.dart`,
`lib/widgets/change_password_dialog.dart`,
`lib/widgets/theme_mode_picker.dart`, `lib/widgets/update_tiles.dart`,
`lib/theme/theme_controller.dart`, `lib/l10n/locale_controller.dart`.

## Purpose

The user's own name and password, and how the app looks on this phone:
language, color and theme. The look is kept on the phone only; it does not
follow the account to another phone.

**Opens from:** "Podešavanja" on the [Više tab](shell.md).

## What it shows

Header: "Podešavanja" (shown in capitals), with a back arrow. The four
section headings below are shown in capitals too.

1. **"Profil"**
   - A row with a badge icon, the user's full name and, under it, the email;
     an edit icon on the right.
   - A row "Promeni lozinku", with a lock icon.
2. **"Jezik"**: three radio rows: "Jezik telefona", "English", "Srpski".
3. **"Boja"**: six leaning color swatches, in this order: "Crvena", "Plava",
   "Topla", "Zelena", "Žuta", "Ljubičasta" (the names are tooltips). The
   chosen one has a tick.
4. **"Tema"**: three choices side by side, each with an icon: "Auto",
   "Svetla", "Tamna". Under them: "Auto prati temu telefona."
5. **"Izgled"**: two choices side by side, each with an icon: "Novi" and
   "Stari". Under them: "Posle izbora se vraćaš na početni ekran." It picks
   which of the app's two interfaces this phone shows; see
   [classic.md](../classic.md). Choosing the other one closes Settings and
   every other open screen, and the app is drawn again from its first
   screen. The classic interface has the same chooser in its Settings.
6. A row **"Proveri ažuriranja"** with "Verzija {x}" under it.
7. A row **"Odjavi se"**.

There is no picture of this screen. The "Tema" chooser alone is drawn in the
lower part of the [calendar picture](../img/v2_kalendar.png).

## Actions

| Tap | Result |
|---|---|
| The name row | the dialog "Izmeni ime" |
| "Promeni lozinku" | the change-password dialog |
| A language | the whole app switches at once |
| A color | the whole app takes that palette at once |
| "Auto" / "Svetla" / "Tamna" | follows the phone, or stays light or dark |
| "Proveri ažuriranja" | checks; a spinner shows on the row meanwhile |
| "Odjavi se" | closes this screen and signs out, back to login |

The result of an update check is the snack bar "Imaš najnoviju verziju." or
"Provera ažuriranja nije uspela.", or the update dialog (see
[shared.md](../shared.md)).

A new install starts on "Jezik telefona", "Crvena" and "Auto". "Srpski" runs
in Latin script, dates and the system's own texts included.

## Dialogs

**"Izmeni ime".** Fields "Ime" and "Prezime"; buttons "Otkaži" / "Sačuvaj".
The new name shows on the row at once.

**Change password.** Title "Promeni lozinku". Fields "Trenutna lozinka",
"Nova lozinka", "Potvrdi novu lozinku", all hidden text.

- Errors: "Obavezno", "Najmanje 6 karaktera", "Lozinke se ne poklapaju"; a
  failure from the server shows as red text inside the dialog.
- Buttons "Otkaži" / "Sačuvaj"; "Sačuvaj" reads "Sačekaj..." while it works.
- On success: "Lozinka je promenjena."

## States

- The name and email come from the live profile, so a rename made elsewhere
  shows without reopening the screen.

## Layout today

- List padding 16. Sections are 16 apart.
- Section headings: 16 italic w800, padding left 4, bottom 8.
- The profile rows, the update row and "Odjavi se" are plain list tiles with
  an icon on the left in `ink`; the language rows are plain radio tiles.
- Color swatches: 48×48, radius 8, leaning 10°, 12 apart, wrapping; each
  filled with its palette's `primary`. The tick on the chosen one is in that
  palette's `onPrimary`: white, or dark on "Žuta".
- Theme choices: a segmented button of three with icons and no check mark,
  as wide as the screen allows; the line under it is 13 in `ink` at 0.65,
  padding 4, 8, 4, 0.
- In the dialogs the fields are 12 apart.

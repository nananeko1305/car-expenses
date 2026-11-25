# Users (admin only)

Code: `lib/screens/users_screen.dart`, `lib/widgets/add_user_dialog.dart`.

## Purpose

The accounts that may use the app. There is no public registration: an
account exists only if the admin makes it here. The admin can also switch an
account off and on again.

**Opens from:** "Korisnici" on the [Više tab](shell.md), a row only the admin
sees.

## What it shows

Header: "Korisnici" (shown in capitals), with a back arrow. Under it, the
sync banner.

1. One row per account, the admin first and the others by name:
   - a leaning block with an icon: a shield for the admin, a person for
     others; the dark block for an active account, a pale one for a disabled
     account;
   - the name;
   - the email;
   - the role and status, joined with " · ": "Admin" or "Korisnik", then "ti"
     on the admin's own row, then "Onemogućen" on a disabled account;
   - on the right, a text button "Onemogući" or "Omogući". The admin's own row
     has none.
2. **Floating button:** "Dodaj korisnika" (shown in capitals), with an
   add-person icon.

There is no picture of this screen.

## Actions

| Tap | Result |
|---|---|
| "Onemogući" | the account loses all access to the data |
| "Omogući" | gives it back |
| "Dodaj korisnika" | the add-user dialog |

## Dialogs

**Add user.** Title "Dodaj korisnika".

- "Ime", "Prezime", "Email", "Početna lozinka". Errors: "Obavezno", "Unesi
  ispravan email", "Najmanje 6 karaktera".
- A failure shows as red text inside the dialog.
- Buttons "Otkaži" / "Dodaj korisnika". The second reads "Sačekaj..." while
  the account is being made: this dialog waits for the answer.
- On success, a snack bar: "Korisnik {email} je napravljen".

No email is sent to the new user; the admin passes the password on.

## States

- **Loading:** a spinner. **Error:** the error text, centered.

## Layout today

- The list has no side padding and 96 at the bottom; rows touch.
- Row: a RaceRow (see [shared.md](../shared.md)): a 36×36 block, 12, the name
  in 15 w600 on one line; 2; the email and, on the next line, the role and
  status, both in 13 `muted`; the text button ends the row.
- The block of a disabled account is a 14% tint of `muted` with the icon in
  `muted`.
- In the dialog the fields are 12 apart.

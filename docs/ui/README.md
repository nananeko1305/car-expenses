# UI map

What every screen of the app shows, what can be done on it, which dialogs it
opens, which states it has, and how it is laid out. Read the page of a screen
before changing it, instead of re-reading its code.

Labels are quoted in Serbian, exactly as in `lib/l10n/app_sr.arb`, because that
is what gets searched for. The English text of a label is in `app_en.arb` under
the same key. Some labels are drawn in capitals (header titles, leaning
buttons, tags, the bottom bar, section titles); the pages quote them as
written and say "shown in capitals".

## How to use it

1. Find the screen in the index below and open its page.
2. The sections up to **States** say what the screen does. They stay true
   through a restyling.
3. **Layout today** is last and separate: order, paddings, radii and font
   sizes. It is the part a redesign rewrites.
4. For colors, shapes and recurring sizes see [look.md](look.md); for pieces
   used on several screens see [shared.md](shared.md).

## Keeping it true

- A change to a screen updates its page **in the same commit**. A page that
  lies is worse than no page.
- Describe what exists. Plans and ideas do not go here.
- Images go in `docs/ui/img/`. There are 15, listed under "Pictures" below.
  They are rendered from widget tests with made-up data, never taken from a
  phone: the repository is public, and a phone screenshot shows real names,
  plates and amounts.
- Examples in these pages use made-up values for the same reason.

## Navigation

```
main.dart
  └─ AuthGate         signed in?  no → login
       └─ ProfileGate profile ok? no → status screen, or the one-time admin claim
            └─ HomeScreen  the shell
                 ├─ tab "Servisi"    services of this month
                 ├─ tab "Kasa"       the wallet
                 ├─ tab "Kalendar"   the calendar
                 ├─ tab "Više"       a list of everything else
                 ├─ sync banner      above the bottom bar
                 └─ bottom bar       "Servisi" | "Kasa" | "Kalendar" | "Više"
```

The tabs share no app bar: each tab draws its own header. The app opens on
"Servisi".

The Više tab lists, in this order:

| # | Row | Opens |
|---|---|---|
| 1 | "Mesečni izveštaj" | report screen |
| 2 | "Pretraga po tablicama" | vehicle search |
| 3 | "Automobili" | vehicles list |
| 4 | "Alat" | tools list |
| 5 | "Za kupovinu" | to-buy list |
| 6 | "Tutorijali" | tutorials (makes) |
| 7 | "Korisnici" | users list, **admin only** |
| 8 | "Podešavanja" | settings |
| 9 | "Odjavi se" | signs out |

Two of these can also be reached from a tab's header: the vehicle search from
the search icon on Services and on the wallet, and the report from the
earnings on Services.

Every screen opened this way is pushed on top of the shell, covers the bottom
bar and has a back arrow. Only the four tabs live inside the shell.

## Index

| Screen | File in `lib/screens/` | Page |
|---|---|---|
| Shell: the four tabs, the bottom bar | `home_screen.dart` (+ `widgets/race_nav_bar.dart`) | [screens/shell.md](screens/shell.md) |
| Više tab | `more_tab.dart` | [screens/shell.md](screens/shell.md) |
| Services tab | `services_tab.dart` | [screens/services.md](screens/services.md) |
| Service form | `repair_form_screen.dart` | [screens/services.md](screens/services.md) |
| Wallet tab | `wallet_tab.dart` | [screens/wallet.md](screens/wallet.md) |
| Wallet entry (deposit, spending) | `wallet_entry_screen.dart` | [screens/wallet.md](screens/wallet.md) |
| Calendar tab | `calendar_screen.dart` | [screens/calendar.md](screens/calendar.md) |
| Monthly report | `report_screen.dart` | [screens/monthly-report.md](screens/monthly-report.md) |
| Tools list | `tools_screen.dart` | [screens/tools.md](screens/tools.md) |
| Tool form | `tool_form_screen.dart` | [screens/tools.md](screens/tools.md) |
| Receipt photo | `receipt_screen.dart` | [screens/tools.md](screens/tools.md) |
| Tutorials: makes | `tutorials_screen.dart` | [screens/tutorials.md](screens/tutorials.md) |
| Tutorials: one make | `tutorial_brand_screen.dart` | [screens/tutorials.md](screens/tutorials.md) |
| Tutorials: one model | `tutorial_model_screen.dart` | [screens/tutorials.md](screens/tutorials.md) |
| Tutorials: new model | `tutorial_model_form_screen.dart` | [screens/tutorials.md](screens/tutorials.md) |
| Vehicles list | `vehicles_screen.dart` | [screens/vehicles.md](screens/vehicles.md) |
| Vehicle history | `vehicle_history_screen.dart` | [screens/vehicles.md](screens/vehicles.md) |
| Vehicle search | `vehicle_search_screen.dart` | [screens/vehicles.md](screens/vehicles.md) |
| To-buy list | `planned_purchases_screen.dart` | [screens/to-buy.md](screens/to-buy.md) |
| Settings | `settings_screen.dart` | [screens/settings.md](screens/settings.md) |
| Users (admin) | `users_screen.dart` | [screens/users.md](screens/users.md) |
| Login | `login_screen.dart` | [screens/auth.md](screens/auth.md) |
| Admin claim | `claim_admin_screen.dart` | [screens/auth.md](screens/auth.md) |
| Status (no access, disabled, error) | `status_screen.dart` | [screens/auth.md](screens/auth.md) |
| Gates | `auth_gate.dart`, `profile_gate.dart` | [screens/auth.md](screens/auth.md) |

## Pictures

All are in `docs/ui/img/`, 780×1688 pixels, in Serbian, in the red palette
unless the table says otherwise. Two scripts draw them from the app's own
widgets with made-up data. They are run by hand, from the project folder;
their names do not end in `_test.dart`, so `flutter test` leaves them alone:

```sh
flutter test test/shots/main_screens.dart --update-goldens --dart-define=OUT=$PWD/docs/ui/img
flutter test test/shots/more_screens.dart --update-goldens --dart-define=OUT=$PWD/docs/ui/img
```

| File | Shows | Theme | Linked from |
|---|---|---|---|
| `v2_servisi.png` | Services tab | light | [services](screens/services.md), [look](look.md) |
| `v2_servisi_dark.png` | Services tab | dark | [services](screens/services.md), [look](look.md) |
| `v2_servisi_plava.png` | Services tab, in the blue palette | light | [services](screens/services.md), [look](look.md) |
| `v2_kasa.png` | Wallet tab, "Evri" off | light | [wallet](screens/wallet.md) |
| `v2_kasa_evri_dark.png` | Wallet tab, "Evri" on | dark | [wallet](screens/wallet.md) |
| `v2_kasa_zuta.png` | Wallet tab, in the yellow palette, whose text on the accent is dark | light | [wallet](screens/wallet.md), [look](look.md) |
| `v2_forma.png` | Service form, new service | light | [services](screens/services.md) |
| `v2_vise.png` | Više tab, as the admin sees it | light | [shell](screens/shell.md) |
| `v2_alat.png` | Tools list: a running, an ending and an expired warranty | light | [tools](screens/tools.md) |
| `v2_tutorijali.png` | Tutorials: one model's links and notes, and under them two make rows | light | [tutorials](screens/tutorials.md) |
| `v2_kupovina.png` | To-buy list, with the three priorities | light | [to-buy](screens/to-buy.md) |
| `v2_izvestaj.png` | Monthly report, by month | light | [monthly-report](screens/monthly-report.md) |
| `v2_kalendar.png` | Calendar: the month switcher and the month grid; under them the "Tema" chooser from Settings | light | [calendar](screens/calendar.md), [settings](screens/settings.md) |
| `v2_prijava.png` | Login | light | [auth](screens/auth.md) |
| `v2_izbor_dark.png` | Option sheet, opened over an otherwise empty screen | dark | [shared](shared.md) |

How the pictures differ from a phone:

- **Shadows show as dark outlines.** The floating buttons have a thick dark
  line around them; on a phone it is a soft shadow.
- **The logo is missing.** Its place is empty on the login screen.
- Both are how Flutter draws in tests, not how the app looks.
- The dates are those of the month the scripts were run in. The month after
  "Servisi" in the Services pictures is written into the script.

Where a picture is put together from widgets and is not the screen itself:

- `v2_forma.png`: the mileage field is labelled "Kilometraža"; the app shows
  "Kilometraža (km)".
- `v2_alat.png`: a hairline runs under the segmented switch; the screen has
  none there.
- `v2_izvestaj.png`: the segmented switch spans the full width and scrolls
  with the rest; on the screen it is as wide as its labels, centered, and
  stays in place.
- `v2_tutorijali.png`: the heading "Marke" and the two make rows under the
  notes belong to another screen, the list of makes, which has no such
  heading.
- `v2_kalendar.png`: the "Tema" chooser is not on the calendar; the day
  heading and the booking rows of the calendar are not drawn.
- `v2_izbor_dark.png`: the word "otvori" in the middle is the script's own
  button.

There is no picture of the vehicles screens, Settings as a whole, Users, the
wallet entry form, the tool form, the receipt screen, the admin claim or the
status screen.

## Who may change what, as the screens show it

- **Services, wallet entries, bookings, cars:** anyone may add; only the author
  or the admin may change or delete. Everyone else gets the same form, read-only,
  with "Ovo mogu da menjaju samo {name} ili admin." on top and no save button.
- **Tools, tutorials, the to-buy list:** anyone may add and change. Tools are
  archived, never deleted.
- **Users:** the admin only.

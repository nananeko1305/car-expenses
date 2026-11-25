# The look

This is the look since 2.0: one accent color on a neutral ground, one
typeface, small radii, hairlines instead of soft cards, and shapes that lean
to the right. The code is in `lib/theme/` (`app_palette.dart`,
`app_colors.dart`, `app_theme.dart`, `theme_controller.dart`) and, for the
leaning shapes, in `lib/widgets/skewed.dart` and
`lib/widgets/slant_header.dart`. A theme cannot lean anything, so the leaning
is done by widgets; they are described in [shared.md](shared.md).

Pictures of it: [img/v2_servisi.png](img/v2_servisi.png) (light),
[img/v2_servisi_dark.png](img/v2_servisi_dark.png) (dark),
[img/v2_servisi_plava.png](img/v2_servisi_plava.png) (the blue palette) and
[img/v2_kasa_zuta.png](img/v2_kasa_zuta.png) (the yellow palette, whose text
on the accent is dark). The full list is in [README.md](README.md).

## What the user can choose

Both choices are in Settings and are kept on the phone.

- **"Boja"**: one of six palettes, below. "Crvena" is first in the list and
  is where a new install starts.
- **"Tema"**: "Auto", "Svetla" or "Tamna". Auto follows the phone and is where
  a new install starts.

## Palettes

A palette is one accent color. It sets three colors by hand: `primary` (the
accent), `deep` (the accent dark enough to read as text on the light ground)
and `onPrimary` (text and icons on the accent). Everything else is the same
in every palette.

| Name (id) | primary | deep | onPrimary |
|---|---|---|---|
| "Crvena" (`crvena`) | `#D90429` | `#B00320` | `#FFFFFF` |
| "Plava" (`plava`) | `#1D4ED8` | `#1A3FAE` | `#FFFFFF` |
| "Topla" (`topla`) | `#C2410C` | `#9A3409` | `#FFFFFF` |
| "Zelena" (`zelena`) | `#0B7A43` | `#075C32` | `#FFFFFF` |
| "Žuta" (`zuta`) | `#FFC400` | `#7A5C00` | `#101216` |
| "Ljubičasta" (`ljubicasta`) | `#6D28D9` | `#5521B5` | `#FFFFFF` |

The accent itself is the same in the light and the dark theme. Three more
colors are worked out from it:

| Color | How it is derived |
|---|---|
| `soft` | `primary` at 12% over white |
| `darkSoft` | `primary` at 24% over `#0E1014` |
| `bright` | `primary` with its lightness raised to at least 0.68: the accent light enough to read as text on the dark ground |

As computed from those rules:

| Name | soft | darkSoft | bright |
|---|---|---|---|
| "Crvena" | `#FAE1E5` | `#3F0D19` | `#FC5F7A` |
| "Plava" | `#E4EAFA` | `#121F43` | `#6F90EC` |
| "Topla" | `#F8E8E2` | `#391C12` | `#F58F65` |
| "Zelena" | `#E2EFE8` | `#0D291F` | `#69F2AE` |
| "Žuta" | `#FFF8E0` | `#483B0F` | `#FFD95C` |
| "Ljubičasta" | `#EDE5FA` | `#251643` | `#A174E6` |

## How widgets read colors

Through `context.colors` (`AppColors`), never from static getters, so they
repaint when the palette or the theme changes.

| Name | Light | Dark | Used for |
|---|---|---|---|
| `primary` | `primary` | `primary` | header blocks, leaning buttons, a switch that is on, the selected day, the bar over the open tab, the focused field border |
| `onPrimary` | `onPrimary` | `onPrimary` | text and icons on the accent |
| `accentText` | `deep` | `bright` | the accent as text on the ground: text buttons, field labels, the open tab's icon and label, "Odjavi se" on the Više tab |
| `soft` | `soft` | `darkSoft` | the receipt card's icon background, the chosen priority row |
| `background` | `#FFFFFF` | `#0E1014` | the screen behind everything; also the text on a dark block |
| `ink` | `#101216` | `#F2F3F5` | text; the fill of the dark blocks (date block, row icon, the "Zarada" tile, the totals block, the selected segment); firm borders (plate, filter, currency, segments) |
| `muted` | `#555C66` | `#A7AEB8` | secondary text, chevrons, small marks, the tabs that are not open |
| `surface` | `#FFFFFF` | `#181B21` | cards, dialogs, sheets, the plate, a filter with nothing chosen |
| `panel` | `#F1F2F4` | `#20242B` | the fill of text fields and of the quiet leaning tiles, the chosen row of an option sheet, the track of the warranty bar |
| `line` | `#DADDE2` | `#2C313A` | hairlines under rows, card and box borders |
| `moneyIn` | `#0A6B3A` | `#5FD08F` | money that came in; a warranty that still runs |
| `moneyOut` | `#B00320` | `#FF8A80` | money that went out; a negative result; the border of a field with an error |

A "dark block" is filled with `ink` and written on in `background`, so it is
near-black with white text in the light theme and near-white with dark text
in the dark theme.

A few texts are `ink` at reduced opacity instead of `muted`: 0.55 (weekday
letters, the person icon on a service row), 0.6 (the detail row of the
report), 0.65 (the label of a running warranty, the line under the theme
choices, the "Prioritet" label) and 0.7 (the author on a service row).

## Colors that do not come from the palette

They are the same in every palette and in both themes.

| Where | Color | Meaning |
|---|---|---|
| Balance, in the wallet header | `#FFD166` | a negative balance, where the text on the accent is light; in "Žuta", whose text on the accent is dark, it is `moneyOut` instead |
| To-buy priority | `#C93A3A`, white text | "Hitno" |
| To-buy priority | `#F2C230`, text `#3A2E00` | "Srednje" |
| To-buy priority | `#2E7D4F`, white text | "Nije hitno" |
| Warranty bar | `#E0A63E` | warranty ends soon |
| Warranty bar | `#D94E4E` | warranty expired |
| Sync banner | `#3B82F6`, white text | "Sinhronizujem..." |
| Sync banner | `#22A06B`, white text | "Sinhronizovano" |
| Receipt screen | black, white icons | the photo viewer |

## Typography

One typeface, Exo 2, bundled in `assets/fonts/` and declared in
`pubspec.yaml` as the family `Exo2`. The theme sets it for every text.

| File | Weight | Style |
|---|---|---|
| `Exo2-Regular.ttf` | 400 | upright |
| `Exo2-Medium.ttf` | 500 | upright |
| `Exo2-SemiBold.ttf` | 600 | upright |
| `Exo2-ExtraBold.ttf` | 800 | upright |
| `Exo2-BoldItalic.ttf` | 700 | italic |
| `Exo2-ExtraBoldItalic.ttf` | 800 | italic |

Italic is used for what leads a screen: header titles, section titles, the
month switcher, the labels of the bottom bar, the floating label of a field,
the amount typed into "Iznos", and amounts shown as figures (the balance, the
earnings, the amount on a row). Text inside a leaning shape leans with the
shape, whatever its own style.

Sizes that recur:

| Text | Size and weight |
|---|---|
| Header title | 28 italic w800, letter spacing −0.5 |
| Text after the header title (the month, on Services) | 14 italic w700 |
| Section title, day heading of the calendar | 16 italic w800 |
| Month switcher, title of an option sheet | 18 italic w800 |
| Row title | 15 w600 |
| Row second line, helper lines | 13, `muted` |
| Amount on a row | 17 italic w800, the currency after it at 65% of that size, w600, upright |
| Big figures in a header | 30 (earnings) and 36 (balance) italic w800 |
| Label of a leaning button | 14 w800 (16 on a floating button, 18 on the button that ends a form), letter spacing 0.3 |
| Label on the bottom bar | 11.5 italic w700 |

## What is shown in capitals

The label stays as written in `app_sr.arb`; the widget turns it into capitals
when drawing it.

- Header titles and the text after them (`SlantHeader`).
- Labels of leaning buttons (`SkewButton`, so also the floating button and
  the button that ends a form) and of leaning tags (`SkewTag`: "Bez naplate"
  on a service row, the role on the Više tab).
- Labels of the bottom bar.
- "Izveštaj" in the Services header.
- Section titles (`SectionTitle`, the headings in Settings, the title of an
  option sheet, the day heading in the calendar).
- The month switcher, the month on a date block, and the weekday letters of
  the month grid.

Not in capitals: row texts, field labels, the filter buttons, the priority
labels, the labels of the three wallet tiles, dialog titles and dialog
buttons.

## Leaning shapes

Leaning is a horizontal skew to the right (`Skewed`), at one of two angles.

| Angle | What leans at it |
|---|---|
| 10° (0.1745 rad) | buttons, the floating button, tags, switches, the filter buttons, the two currency buttons, the priority label, the "Izveštaj" chip, the color swatches in Settings |
| 8° (0.1396 rad) | blocks: the date block, the row icon, the icon of a wallet row, the three wallet tiles, the totals block of a car, the earned block and the two count tiles of the report |

The header block does not skew. Its bottom edge is cut at a slant: 22 lower
on the left than on the right. Two stripes run through it, skewed by 0.42 rad
(about 24°), in `onPrimary` at 14%: one 16 wide, 96 from the right edge, and
one 8 wide, 66 from the right edge.

## Shapes and sizes from the theme

Material 3. The color scheme is seeded from `primary`, then set by hand:
`primary`, `onPrimary`, surface = `background`, text on it = `ink`, its
variant = `muted`, outlines = `line`.

| Thing | Value |
|---|---|
| Screen background | `background` |
| Corner of fields, filled buttons, the snack bar | 8 |
| App bar (where the plain one is used) | `primary` fill, `onPrimary` content, no elevation, title left-aligned, 24 italic w800 |
| Status and navigation bar | transparent. Over an accent block the icons take the lightness of the text on it (light, or dark in "Žuta"); elsewhere dark icons on light, light icons on dark |
| Card | radius 10, a 1 px border in `line`, `surface` fill, no elevation, no margin |
| Dialog | `surface`, radius 12 |
| Bottom sheet | `surface`, top corners 16 |
| Divider | `line`, 1 thick, taking 1 of height |
| Text field | filled with `panel`, dense, padding 12 horizontal and 14 vertical, radius 8, no border at rest |
| Text field, focused | 2 px border in `primary` |
| Text field, error | 1.5 px border in `moneyOut`, 2 px when focused |
| Floating label of a field | `accentText`, italic w700 |
| Filled button | `primary`, `onPrimary` text, full width, at least 52 high, radius 8, text 16 w800 |
| Text button | `accentText`, w600 |
| Segmented button | radius 6, 1.5 px border in `ink`; the selected segment is `ink` with `background` text, the others `background` with `ink` text; w800 |
| Material floating button | `primary`, `onPrimary`, elevation 3, radius 8; no screen uses it, they use the leaning one |
| List tile icons | `ink` |
| Snack bar | floating, radius 8; `ink` with white text in light, `panel` with `ink` text in dark |

## Sizes that recur without being in the theme

| Thing | Value |
|---|---|
| Lists | rows run edge to edge with a 1 px hairline under each; no gap between rows |
| List bottom padding | 96 under a floating button; 32 or 16 where there is none |
| Row (`RaceRow`) | at least 54 high, padding 16 left, 8 top and bottom, 16 right (6 when something ends the row) |
| Block that leads a row | 36×36, radius 8, icon 18; a date block is 44×44 |
| Gap between the leading block and the text | 12 |
| Form screen padding | 16, with 12 or 14 between fields |
| Header | a 52 high bar under the status bar, then 30 to the lowest point of the slant; 82 in all where it holds only the title |
| Leaning button | at least 44 high, radius 6, 12 horizontal padding |
| Floating button | 50 high, lifted by 4 |
| Button that ends a form | 52 high, 6 kept free at each end |
| Leaning switch | 46×26, radius 6, 2 px border, an 18×18 knob |
| Leaning tag | padding 7×1, 1.5 px border, radius 4, text 11 w800 |
| Plate | padding 6 horizontal, 1.5 px border in `ink`, radius 4, text 12 w800 |
| Section title | padding 16, 18, 16, 6 |
| Bottom bar | 60 high, a hairline on top, a 4 px bar in `primary` over the open tab |
| Empty-state text | centered, padding 48 vertical and 24 horizontal (24 vertical inside a longer page) |

## Dates and numbers

- Amounts: two decimals with the locale's separators, then "RSD" or "€":
  `12.345,50 RSD`, `110,00 €`. Dinars and euros are never added together; where
  both exist they are two lines, dinars first.
- The three tiles of the wallet's month show dinars as the bare number
  (`173.000,00`) and euros with their sign (`150,00 €`).
- Serbian runs in Latin script (`sr_Latn`, set in `lib/main.dart`), so month
  names, dates and the system's own texts (the date picker, tooltips) are
  Latin like the labels.
- Dates on rows and labels: day, short month, year: "25. nov 2026.". A
  wallet row leaves the year out: "25. nov". A date block shows the day over
  the short month in capitals.
- Dates in form fields have the month written out: "25. novembar 2026.". The
  date on the service form, which shares its line with the mileage, is digits
  only: "25. 11. 2026.".
- The month switcher shows "novembar 2026." in capitals; the day heading of
  the calendar shows "sreda, 25. novembar" in capitals.

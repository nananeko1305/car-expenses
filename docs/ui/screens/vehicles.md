# Vehicles: the list, a car's history, the search and the dialog

Code: `lib/screens/vehicles_screen.dart`,
`lib/screens/vehicle_history_screen.dart`,
`lib/screens/vehicle_search_screen.dart`, `lib/widgets/vehicle_dialog.dart`,
`lib/widgets/totals_card.dart`, `lib/widgets/plate_chip.dart`.

Cars are shared: everyone sees every car. Its author or the admin may change
or delete one. A car that has services cannot be deleted.

There is no picture of these screens. A plate and a service row as they are
drawn here can be seen in the [Services picture](../img/v2_servisi.png).

---

## Vehicles list

### Purpose

Every car the workshop knows, by name.

**Opens from:** "Automobili" on the [Više tab](shell.md).

### What it shows

Header: "Automobili" (shown in capitals), with a back arrow. Under it, the
sync banner.

1. One row per car, sorted by name: a leaning dark block with a car icon, the
   car's name, and under it the plate drawn as a plate and the name of
   whoever added it. A car without a plate shows only that name.
   - For whoever may change the car: edit (tooltip "Izmeni") and delete
     (tooltip "Obriši") icons on the right.
   - For everyone else: a chevron.
2. **Floating button:** "Dodaj auto" (shown in capitals).

### Actions

| Tap | Result |
|---|---|
| A car | that car's history |
| Edit | the car dialog |
| Delete | asks "Obrisati {name}?" with "Ovo ne može da se poništi." |
| "Dodaj auto" | the car dialog, empty |

A car with services is not deleted; a snack bar says "Ovaj auto ima servise,
pa ne može da se obriše."

### States

- **Empty:** "Još nema automobila.", centered on the screen.

### Layout today

- The list has no side padding and 96 at the bottom; rows touch.
- Row: a RaceRow (see [shared.md](../shared.md)): at least 54 high, a 36×36
  block, 12, the name in 15 w600 on one line; 4; the plate (12 w800 in its
  box), 8, the author in 13 `muted`. The two icon buttons, or a chevron in
  `muted` 8 from the edge, end the row.

---

## Car dialog

Title "Novi auto" or "Izmena automobila".

- "Marka i model", hint "npr. Škoda Octavia", required.
- "Registarska oznaka", hint "npr. BG-123-AB".
- "Broj šasije (VIN)", helper "Preporučeno. Sa saobraćajne dozvole, polje E."
  Error: "Broj šasije ima 17 slova i brojeva, bez I, O i Q".
- Buttons "Otkaži" / "Sačuvaj".

Fields are 12 apart. Opens from the vehicles list, from a car's history, and
from "Dodaj auto" on the Services tab while there are no cars.

---

## Car history

### Purpose

One car: what it is, what it has cost in total, and every service it had.

**Opens from:** a car on the vehicles list; a result in the search.

### What it shows

Header: "Istorija servisa" (shown in capitals), with a back arrow; an edit
icon (tooltip "Izmeni") for whoever may change the car.

1. **The car:** the plate drawn as a plate, large, with the car's name beside
   it; "Šasija: {VIN}" when there is one, which can be selected and copied;
   "Poslednja kilometraža: 123.456 km" when any service recorded a mileage.
2. The **totals block**, a leaning dark block: "Ukupno", the sum of all its
   services per currency, and "N servisa".
3. One [service row](services.md) per service, newest first, without the
   plate and the car's name on each; the mileage starts the second line in
   their place.
4. **Floating button:** "Novi servis" (shown in capitals).

### Actions

| Tap | Result |
|---|---|
| Edit | the car dialog |
| A service row | the [service form](services.md) |
| "Novi servis" | an empty service form with this car chosen |

### States

- **No services:** "Ovaj auto još nema servisa." The totals block still
  shows, with "0,00 RSD" and "0 servisa".
- **The car was deleted while this was open:** a header with no title and
  "Još nema automobila.", centered.

### Layout today

- One scrolling list with no side padding and 96 at the bottom.
- The car: padding 16, 4, 16, 0. The plate in 18 w800 in its box; 10; the
  name in 17 w800, up to 2 lines. 6; the VIN line in 13 `muted`; 2; the
  mileage line in 13 `muted`.
- Totals block: padding 20, 10, 20, 12 around it. Leaning 8°, `ink` fill,
  radius 8, padding 14, 8, 14, 10; "Ukupno" in 12 w600; the sums in 22 w800,
  shrinking to fit; at the right end, bottom-aligned, "N servisa" in 13 w600;
  all in `background`.
- A hairline, then the service rows, which touch.
- Empty text: centered, 40 vertical.

---

## Vehicle search

### Purpose

Find a car by its plate, its name or its chassis number.

**Opens from:** the search icon in the header of the Services and Wallet
tabs; "Pretraga po tablicama" on the [Više tab](shell.md).

### What it shows

App bar: a back arrow, and as the title the search field itself, hint
"Tablica, auto ili broj šasije", with a search icon on the left and, once
there is text, an x that clears it. The keyboard opens at once and types in
capitals.

1. One row per matching car, sorted by name: a leaning dark block with a car
   icon; the car's name; under it the plate drawn as a plate and "N servisa"
   (all time); a chevron. With nothing typed, every car is listed.

Matching ignores spaces, dashes and case in the plate, so `bg123ab` finds
`BG-123-AB`. The chassis number needs at least four characters.

### Actions

| Tap | Result |
|---|---|
| A result | that car's history |
| The x | clears the field |

### States

- **Nothing found:** "Nema pronađenih automobila.", centered on the screen.

### Layout today

- This screen has the plain app bar, not the slanted header: `primary` fill,
  the back arrow in `onPrimary`, and the search field drawn as the other text
  fields are (a `panel` fill, radius 8).
- The list has no side padding and 16 at the bottom; rows touch.
- Row: a RaceRow: a 36×36 block, 12, the name in 15 w600 on one line; 4; the
  plate (13 w800 in its box), 8, the count in 13 `muted`; a chevron in
  `muted` 8 from the edge.

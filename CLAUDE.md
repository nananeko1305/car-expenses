# Car Expenses: architecture map

Android-only Flutter app for a car workshop: services, a shared wallet, tools, a
calendar and tutorials. Accounts exist only if the admin creates them.

The README below is imported and holds the product rules, the data model, the
calendar push design and the release process. This file adds what the README
does not: how the code fits together, and what breaks if you forget it.

@README.md

The global guidelines about Go layout and Neutrino libraries do not apply here:
there is no Go in this repository.

**Keep this true:** a change that alters anything below updates this file in the
same commit. Do not add version numbers, line counts or lists of every file;
they go stale. The repository is **public**, so nothing secret goes here.

## System

```
                     ┌─ Firebase Auth      email/password, no self sign-up
                     ├─ Firestore          direct from the app, offline cache on
 Android app ────────┼─ Cloudinary         receipt photos, unsigned preset
 (Flutter)           ├─ Push worker        POST /announce, POST /cancel
                     ├─ GitHub Pages       version.json, the update check
                     └─ FCM                receives pushes

 Push worker ────────┬─ Firestore REST     service account, bypasses the rules
 (Cloudflare, cron)  └─ FCM v1             per-phone calendar pushes

 GitHub Actions ─────┬─ GitHub Release     the APK
 (push to main)      ├─ GitHub Pages       version.json, download page
                     └─ FCM topic          `releases`, every install
```

There is no backend of our own. The app talks to Firestore directly, so
**`firestore.rules` is the security boundary** for everything the app does. The
worker uses a service account, which skips those rules, so **its own checks in
`push_worker/src/index.js` are the only boundary on that path**: it verifies the
Firebase ID token and re-checks the account and the author itself.

## Code map

Start-up: `main.dart` → `AuthGate` (signed in?) → `ProfileGate` (profile,
disabled, or the one-time admin claim) → `HomeScreen`. `AuthGate` keys
`ProfileGate` by uid, so switching accounts resets all state below it.

| Path | Holds |
|---|---|
| `lib/models/` | Immutable classes with `fromDoc`/`toMap`, and the pure logic: `Report`, `WalletMovement` balances, warranty dates |
| `lib/money/` | Parsing and formatting of amounts |
| `lib/services/` | Singleton repositories (`XRepository.instance`), `LiveData`, push, auth, updates, receipts |
| `lib/screens/` | Full screens; `HomeScreen` is the shell with two tabs and the drawer |
| `lib/widgets/` | Reusable pieces, dialogs and form fields |
| `lib/l10n/` | `app_en.arb` (template) and `app_sr.arb`; the generated Dart is committed |
| `lib/theme/` | Palettes and `context.colors`; use these, not hard-coded colors |
| `push_worker/src/` | `index.js` routes and rules, `google.js` Firestore and FCM calls, `message.js` pure text and dates |
| `android/app/src/main/` | `MainActivity.kt` creates notification channels; `res/values*/strings.xml` holds push titles |

## How the app works

- **Reads go through `LiveData`.** `HomeScreen` owns one per session and passes
  it down as `data`, so screens do not open their own listeners. The exceptions
  are `ProfileGate`, which runs before `LiveData` exists, and `SettingsScreen` and
  `UsersScreen`, which watch users directly. It listens to whole collections and
  resubscribes with backoff, because a Firestore listener that errors never
  recovers. Filtering happens on the client, which is why
  `firestore.indexes.json` is empty; a query that needs a composite index would be
  the first.
- **`LiveData.ready` covers only vehicles, repairs, users and entries.** The rest
  stay out on purpose, so a problem in tools or the calendar cannot hold up the
  main tabs. Those screens handle their own null state.
- **Writes go through `saveInBackground`; do not await a Firestore write in UI.**
  The future does not complete offline. The screen closes at once, `SyncBanner`
  shows progress, and a failure surfaces as a snackbar. The two exceptions are
  `claimAdmin` and `createUser`, whose screens wait for the result.
- **Need an id inside a batch? Mint it with `.doc()`, not `add()`.** `add()` only
  returns once the server answers. See `PurchaseRepository`. Inside a batch,
  rules' `exists()` sees the state before the batch.
- **Money is an `int` in minor units**, and RSD and EUR are never added together.
- **Balances and reports are computed, never stored**, so they cannot drift.
- **User-visible text goes through `AppLocalizations`**, in both `.arb` files,
  then `flutter gen-l10n`. Firebase errors go through `errorText`.

## Who may do what

| Records | Create | Change | Delete |
|---|---|---|---|
| vehicles, repairs, appointments, walletEntries | any active user | author or admin | author or admin |
| tools | any active user | any active user | nobody; they are archived |
| tutorials (all four collections) | any active user | any active user | any active user |
| users | admin, plus the one-time admin claim | self (name); admin (others' name, `disabled`) | nobody |

Nobody may rewrite the author field. These limits are **in the app only**, since
rules cannot express them, so a new client path must repeat them:

- Spending cannot take a currency below zero (`WalletMovement.available`).
- A car with services cannot be deleted (`VehicleRepository.hasRepairs`).
- Spending that bought a tool cannot be deleted (`PurchaseRepository.hasTool`).
- A make with models cannot be deleted; deleting a model batch-deletes its links
  and notes (`TutorialRepository`).

## What a change has to touch

**New Firestore collection:** the rules, a model, a repository, a `_watch` in
`LiveData`, and the README data model table. Deploy the rules first.

**New field:** old documents and old APKs both exist. Rules read it with
`d.get('field', default)` and `fromDoc` tolerates its absence. See `vin`, `year`,
`engine` and `toWallet`.

**New push type:** `message.js`; the title in `res/values/strings.xml` and
`res/values-sr/strings.xml`; `res/raw/keep.xml`, or resource shrinking drops it and
the notification arrives empty; the key list in the CI step "Verify notification
strings"; and `AppointmentPush._kinds` for the foreground snackbar. A new channel
also goes in `MainActivity.kt`.

## Shipping

| Piece | Deployed by | When |
|---|---|---|
| App | CI, on any push to `main` | Merging is the release |
| `firestore.rules` | Hand: `firebase deploy --only firestore:rules` | **Before** the merge that needs it |
| Push worker | Hand: `npx wrangler deploy` from `push_worker/` | **Before** the merge that needs it |

- Work goes on `dev`; a PR from `dev` to `main` ships. The owner merges the PRs.
- **Every merge into `main` reaches every phone.** Even a docs-only merge builds
  an APK and notifies everyone. Docs can wait on `dev` for the next real release.
  The one exception is a merge that touches only the download page
  (`.github/pages/`, `pages.yml`): `pages.yml` redeploys the page for the current
  APK and keeps the live `version.json`, with no release and no push.
- **The commit type sets the version:** `feat` bumps the minor, anything else the
  patch, a breaking change the major. Use Conventional Commits with a scope, as in
  `feat(calendar): …`.
- The current version is the latest `v*` git tag. `pubspec.yaml` is only a floor,
  so do not read the version from it.
- Two different service accounts send pushes: `FCM_SERVICE_ACCOUNT` (GitHub secret,
  release pushes) and `GOOGLE_SERVICE_ACCOUNT` (Cloudflare secret, calendar pushes).

## Testing

```sh
flutter analyze && flutter test       # the same gate CI runs before a release
cd push_worker && npm test            # node --test, with a fake fetch
```

There is no fake Firestore, and repositories bind `FirebaseFirestore.instance`
when created, so tests cannot construct them. Put logic worth testing in `models/`
or take its dependencies as arguments, as `AppointmentAnnouncer` and
`cancelAppointment` do.

The worker's fake `fetch` does not prove Firestore behaves that way: a PATCH with a
precondition passed there and always lost against the emulator, which is why
`writeIf` uses `:commit`. Run real Firestore changes against the emulator too.

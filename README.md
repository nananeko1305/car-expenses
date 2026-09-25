# Car Expenses

Android app (Flutter + Firebase) for tracking car service and repair costs:
date, amount (RSD or EUR), mileage and description, per car. English UI
with Serbian localization.

Firebase project: `car-expenses-260921` (Firestore in `eur3`).

## Accounts

There is no public registration and no emails are sent to new users.

1. Enable **Email/Password** sign-in in the Firebase console
   (Authentication → Sign-in method).
2. Create the first account in the console (Authentication → Users → Add user).
3. Sign in with it in the app, enter first/last name and tap **Become admin**.
   This works exactly once; the `meta/admin` document then locks the role.
4. The admin adds more users from the app (menu → Users → Add user: name,
   email, initial password) and can disable / re-enable them. A disabled
   user loses all data access.

Users change their own name and password in Settings.

## How data is shared

- **Services and cars are shared**: everyone sees everything. Only the
  author of a record (or the admin) can edit or delete it.
- **Wallet**: a shared cash box with a balance per currency (RSD, EUR).
  Every service with "Add amount to wallet" on counts as income. Anyone can
  add funds or record spending (amount, what for, date, who).
- **Tools**: everything that is not consumable, with its warranty. Spending
  from the wallet offers to record the tool it bought, and the tool keeps a
  link back to that spending. A tool is archived, never deleted, so the
  spending is never dragged along with it; spending that bought a tool
  cannot be deleted either.
- **Receipts** are photographed in the app and stored on Cloudinary, not in
  Firebase. The cloud and preset names are build inputs
  (`--dart-define=CLOUDINARY_CLOUD=…`, `--dart-define=CLOUDINARY_PRESET=…`,
  set as repository secrets); a build without them simply hides the receipt
  controls.
- A car that has services cannot be deleted.

## Data model

| Collection           | Fields                                                              |
|----------------------|---------------------------------------------------------------------|
| `users/{uid}`        | `email`, `firstName`, `lastName`, `role` (`admin`/`user`), `disabled` |
| `vehicles/{id}`      | `ownerId` (author), `name`, `plate`                                 |
| `repairs/{id}`       | `ownerId` (author), `vehicleId`, `date`, `amountMinor`, `currency`, `mileage`, `description`, `toWallet` |
| `walletEntries/{id}` | `type` (`deposit`/`withdrawal`), `amountMinor`, `currency`, `description`, `date`, `userId` (who), `createdBy` (author) |
| `tools/{id}`         | `ownerId` (author), `name`, `purchaseDate`, `warrantyAmount`, `warrantyUnit` (`months`/`years`), `warrantyEndsAt`, `amountMinor`, `currency`, `entryId`, `receiptUrl`, `notify`, `archived` |
| `meta/admin`         | `uid` of the admin (one-time claim marker)                          |

`warrantyEndsAt` mirrors the date computed from `purchaseDate` and the
duration; the app always recomputes it and never reads it back.

Amounts are stored in minor units (para / cents) as integers. The wallet
balance is computed from services + entries, never stored, so it cannot
drift. All access rules live in [firestore.rules](firestore.rules).

## Release

Every push to `main` runs [release-apk.yml](.github/workflows/release-apk.yml):
analyze → test → signed release APK (Flutter, pub and Gradle cached) →
GitHub Release → download page on GitHub Pages with a QR code.
Day-to-day work goes to `dev`; merge into `main` to ship.

Versions are `major.minor.patch`, worked out in CI from the commit messages
since the last tag: a `feat` bumps the minor, anything else the patch, and a
breaking change the major. The version in `pubspec.yaml` is a floor — raise
it by hand to force a bigger number, such as a deliberate 2.0.0. Android's
version code is the workflow run number; it keeps installs upgradable and is
never shown in the app.

Signing uses these repository secrets: `ANDROID_KEYSTORE_BASE64`,
`ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
Without them the build falls back to debug signing (installs then can't be
updated in place). Keep a backup of the keystore — losing it means users
must uninstall to get new versions.

## Commands

```sh
flutter run                           # run on a connected device/emulator
flutter test                          # unit tests
flutter build apk --release           # release APK
firebase deploy --only firestore      # deploy rules + indexes
flutter gen-l10n                      # after editing lib/l10n/*.arb
```

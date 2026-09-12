# Membership Wallet

Offline-first Flutter app for storing supermarket/store membership barcodes and QR codes.
No backend, no accounts, no network access — all data lives on-device.

## Features

- Scan an existing membership card (QR, Code128, Code39, EAN-13, UPC-A, PDF417, Data Matrix, Aztec) or enter its number manually
- Full-screen code display with screen wakelock and brightness boost for checkout
- Optional biometric/PIN app lock
- Local JSON export/import for backups
- Store logo upload with an initial-letter avatar fallback

## Getting started

```sh
flutter pub get
flutter run
```

## Project structure

```
lib/
  models/     # MembershipCard + CodeFormat Hive models
  data/       # CardRepository, SettingsRepository (Hive box access)
  screens/    # Wallet home, add/edit card, card detail, settings
  widgets/    # CardTile, CodeRenderer, LogoAvatar, ScannerOverlay
  utils/      # format_mapper (scanner <-> code format), BackupService
```

## Testing

```sh
flutter analyze
flutter test
```

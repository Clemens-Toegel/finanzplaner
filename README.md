# Pilo

Pilo is a Flutter app to capture, organize, and review expenses with fast on-device OCR and clean export options.

## What it does

- Track expenses for **personal** and **business** accounts
- Scan receipts/documents with **offline OCR** (camera + gallery)
- Attach scanned files directly to expense entries
- Add optional **sub-items** and notes
- Browse expenses grouped by month with sticky headers
- Multi-select entries for quick bulk delete (with confirmation)
- Export data from settings:
  - PDF report
  - Excel for external processing

## Key UX highlights

- Branded Pilo mascot visuals (logo + scanning animation)
- Single details sheet + extra details sheet for sub-items/notes
- Attachment download/share from expense detail view
- Account-aware theming (including bottom navigation state color)

## Tech stack

- Flutter (Material 3)
- Provider (state management)
- sqflite (local persistence)
- freezed + json_serializable (models/codegen)
- google_mlkit_text_recognition + image_picker (OCR input)
- pdf + printing (PDF export)
- excel + share_plus (Excel export/share)

## Project structure

```text
lib/
  app.dart
  main.dart
  data/
    purchase_repository.dart
  models/
  screens/
  services/
  state/
  theme/
  widgets/
```

## Getting started

```bash
flutter pub get
flutter run
```

## Useful commands

```bash
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Branding assets and guideline:
- `assets/branding/`
- `docs/brand-guideline-belegpilot.md`

## Notes

- Data is stored locally in SQLite (`purchase_tracker.db`)
- OCR runs on-device
- iOS deployment target is 15.5+

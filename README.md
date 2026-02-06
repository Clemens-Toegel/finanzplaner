# Finanzplaner (Tax Refund Expenses)

A Flutter app to track **tax-deductible expenses** (Austria-focused), split by **personal** and **business** accounts.

It helps you:
- collect expense receipts in one place,
- mark items as deductible/non-deductible,
- review totals and top categories,
- export a structured **PDF report** for your tax advisor.

## Features

- **Expense management**
  - Add, edit, and delete expenses
  - Fields: description, vendor, amount, category, date, deductible flag, notes
  - Optional **sub-items** per expense (line items), including subtotal support
- **Offline OCR bill scanning**
  - On-device OCR (no cloud upload)
  - Scan **shop receipts** from camera
  - Scan **A4 invoices** from camera or photo library
  - OCR can prefill description/vendor/date/amount and sub-items
- **Guided entry flow**
  - 3-page add/edit modal (details → sub-items → notes)
  - Bottom action rows for navigation and save/cancel
  - Unsaved changes confirmation before closing
- **Account separation**
  - Switch between `personal` and `business` expense accounts
  - Account-specific category presets
  - Account settings per account (display name, business company register number)
- **Dashboard**
  - Total amount
  - Deductible total
  - Non-deductible total
  - Average expense
  - Top categories
- **Expenses list**
  - Sorted by purchase date (newest first)
  - Grouped by month
  - Sticky month section header while scrolling
- **PDF export**
  - Month-grouped report with report metadata
  - Includes totals and deductible summary
  - Sub-items are rendered as dedicated rows under their parent expense
- **Localization**
  - German (`de`) and English (`en`) strings
  - App currently starts with German locale by default

## Tech Stack

- **Flutter** (Material 3)
- **sqflite** for local SQLite persistence
- **freezed** + **json_serializable** for immutable model/codegen
- **intl** for date/currency formatting
- **pdf** + **printing** for export/share
- **google_mlkit_text_recognition** + **image_picker** for offline OCR bill scanning

## Project Structure

```text
lib/
  app.dart                       # App + theme + localization setup
  main.dart                      # Entry point
  data/
    purchase_repository.dart     # SQLite CRUD
  models/
    purchase_item.dart
    expense_sub_item.dart
    account_settings.dart
    ocr_bill_data.dart
    expense_account_type.dart
  screens/
    purchase_home_page.dart      # Dashboard + expenses + add/edit sheet
    purchase_detail_page.dart
  services/
    pdf_exporter.dart            # PDF generation and printing
    offline_bill_ocr_service.dart
  localization/
    app_localizations_ext.dart   # Account/category helper extensions
  l10n/
    app_de.arb
    app_en.arb
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Xcode (iOS) / Android Studio (Android) depending on target platform

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Useful Commands

### Analyze

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

### Regenerate model code (if model annotations change)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Regenerate localization code (if ARB files change)

```bash
flutter gen-l10n
```

## Notes

- Data is stored locally in SQLite (`purchase_tracker.db`) on device.
- Expenses are shown sorted by purchase date (newest first).
- PDF export is generated on-device and opened via the platform print/share flow.
- iOS deployment target is set to **15.5** (required by ML Kit OCR plugins).

## License

Private/internal project (`publish_to: none`).

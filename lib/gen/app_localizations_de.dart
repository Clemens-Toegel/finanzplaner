// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Pilo';

  @override
  String get taxRefundPurchasesTitle => 'Pilo';

  @override
  String get exportPdfTooltip => 'PDF exportieren';

  @override
  String get exportSingleExpensePdfTooltip =>
      'Diese Ausgabe als PDF exportieren';

  @override
  String get exportSingleExpensePdfErrorMessage =>
      'Diese Ausgabe konnte nicht als PDF exportiert werden.';

  @override
  String get expenseAccountLabel => 'Ausgabenkonto';

  @override
  String get accountSettingsTitle => 'Kontoeinstellungen';

  @override
  String get accountDisplayNameLabel => 'Kontobezeichnung';

  @override
  String get firmenbuchnummerLabel => 'Firmenbuchnummer';

  @override
  String get firmenbuchnummerValidation =>
      'Nur Buchstaben, Zahlen, Leerzeichen, / und - sind erlaubt.';

  @override
  String get saveSettingsAction => 'Einstellungen speichern';

  @override
  String get accountSettingsSavedMessage => 'Kontoeinstellungen gespeichert.';

  @override
  String get dataExportTitle => 'Datenexport';

  @override
  String get exportExcelForTaxConsultantAction =>
      'Excel für die Steuerberatung exportieren';

  @override
  String get exportExcelSuccessMessage => 'Excel-Datei ist zum Teilen bereit.';

  @override
  String get exportInProgressMessage => 'Export läuft…';

  @override
  String get exportDateRangeTitle => 'Exportzeitraum auswählen';

  @override
  String get confirmDateRangeAction => 'Zeitraum verwenden';

  @override
  String get noItemsInDateRangeMessage =>
      'Im ausgewählten Zeitraum wurden keine Ausgaben gefunden.';

  @override
  String get discardChangesTitle => 'Änderungen verwerfen?';

  @override
  String get discardChangesMessage =>
      'Du hast ungespeicherte Änderungen in diesem Formular.';

  @override
  String get discardChangesAction => 'Verwerfen';

  @override
  String selectionCountLabel(int count) {
    return '$count ausgewählt';
  }

  @override
  String get deleteSelectionTooltip => 'Auswahl löschen';

  @override
  String get clearSelectionTooltip => 'Auswahl beenden';

  @override
  String get deleteSelectedExpensesTitle => 'Ausgewählte Ausgaben löschen?';

  @override
  String deleteSelectedExpensesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# Einträge werden gelöscht.',
      one: '# Eintrag wird gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String get subItemsExceedTotalValidation =>
      'Unterpositionen dürfen nicht höher als der Ausgabenbetrag sein.';

  @override
  String get subItemAmountExceedsTotalValidation =>
      'Diese Unterposition ist höher als der Ausgabenbetrag.';

  @override
  String get remainingForSubItemsLabel => 'Verbleibend für Unterpositionen';

  @override
  String get accountLabelPersonal => 'Private Ausgaben';

  @override
  String get accountLabelBusiness => 'Betriebliche Ausgaben';

  @override
  String get accountLabelInSentencePersonal => 'private Ausgaben';

  @override
  String get accountLabelInSentenceBusiness => 'betriebliche Ausgaben';

  @override
  String get addPurchase => 'Ausgabe hinzufügen';

  @override
  String get addPurchaseTitle => 'Ausgabe hinzufügen';

  @override
  String get editPurchaseTitle => 'Ausgabe bearbeiten';

  @override
  String get editPurchaseAction => 'Bearbeiten';

  @override
  String get savePurchaseAction => 'Speichern';

  @override
  String get deletePurchaseAction => 'Löschen';

  @override
  String get deletePurchaseTitle => 'Ausgabe löschen?';

  @override
  String get deletePurchaseMessage =>
      'Möchtest du diese Ausgabe wirklich löschen?';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get confirmDeleteAction => 'Löschen';

  @override
  String get purchaseDetailsTitle => 'Ausgabedetails';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get descriptionValidation => 'Bitte eine Beschreibung eingeben.';

  @override
  String get vendorLabel => 'Anbieter';

  @override
  String get amountLabel => 'Betrag (€)';

  @override
  String get amountValidation => 'Bitte einen Betrag eingeben.';

  @override
  String get amountInvalidValidation => 'Bitte einen gültigen Betrag eingeben.';

  @override
  String get categoryLabel => 'Kategorie';

  @override
  String get dateOfPurchaseLabel => 'Kaufdatum';

  @override
  String get pickDate => 'Auswählen';

  @override
  String get vatDeductibleLabel => 'In Österreich vorsteuerabzugsfähig';

  @override
  String get notesLabel => 'Notizen für die Steuerberatung';

  @override
  String get addBeforeExport =>
      'Bitte zuerst Ausgaben hinzufügen, bevor exportiert wird.';

  @override
  String get emptyStateTitle => 'Ausgaben einfach erfassen und organisieren';

  @override
  String emptyStateSubtitle(Object account) {
    return 'Füge jeden Beleg für $account hinzu, damit du alles übersichtlich an einem Ort hast.';
  }

  @override
  String get dashboardTabLabel => 'Analyse';

  @override
  String get expensesTabLabel => 'Ausgaben';

  @override
  String get totalAmountLabel => 'Gesamtsumme';

  @override
  String get averageExpenseLabel => 'Durchschnitt pro Ausgabe';

  @override
  String get nonDeductibleTotalLabel => 'Nicht absetzbar';

  @override
  String get topCategoriesLabel => 'Top-Kategorien';

  @override
  String get deductibleTotalLabel => 'Absetzbare Summe';

  @override
  String itemsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# Einträge erfasst',
      one: '# Eintrag erfasst',
    );
    return '$_temp0';
  }

  @override
  String get unknownVendor => 'Unbekannter Anbieter';

  @override
  String get deductibleLabel => 'Absetzbar';

  @override
  String get notDeductibleLabel => 'Nicht absetzbar';

  @override
  String get offlineOcrPrivacyNote =>
      'Belege werden offline auf dem Gerät gescannt. Keine Bild- oder Textdaten verlassen dein Gerät.';

  @override
  String get scanReceiptAction => 'Kassenbon scannen';

  @override
  String get scanDocumentAction => 'A4-Rechnung scannen';

  @override
  String get ocrNoTextFound => 'Kein lesbarer Text auf dem Beleg gefunden.';

  @override
  String get ocrNoTextFoundWithAttachment =>
      'Kein lesbarer Text auf dem Beleg gefunden. Das Belegfoto wurde angehängt.';

  @override
  String get ocrAppliedMessage =>
      'Belegdaten wurden in das Formular übernommen.';

  @override
  String get ocrErrorMessage =>
      'Belegscan fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get imageSaveFailedMessage => 'Bild konnte nicht gespeichert werden.';

  @override
  String get secondaryImageAddedMessage => 'Zusätzliches Bild hinzugefügt.';

  @override
  String get renameImageTitle => 'Bildname ändern';

  @override
  String get nameLabel => 'Name';

  @override
  String get scanFromCameraAction => 'Foto aufnehmen';

  @override
  String get scanFromGalleryAction => 'Aus Fotos auswählen';

  @override
  String get receiptAttachedLabel => 'Beleg angehängt';

  @override
  String scanningReceiptProgress(Object dots) {
    return 'Pilo scannt deinen Beleg$dots';
  }

  @override
  String get receiptFileNotFoundMessage =>
      'Die Belegdatei wurde nicht gefunden.';

  @override
  String get receiptSectionTitle => 'Beleg';

  @override
  String get downloadReceiptAction => 'Beleg herunterladen';

  @override
  String get additionalImagesSectionTitle => 'Zusätzliche Bilder';

  @override
  String get additionalImagesAddAction => 'Zusätzliche Bilder hinzufügen';

  @override
  String additionalImagesCountAction(int count) {
    return 'Zusätzliche Bilder ($count)';
  }

  @override
  String get renameImageTooltip => 'Namen ändern';

  @override
  String get moveUpTooltip => 'Nach oben';

  @override
  String get moveDownTooltip => 'Nach unten';

  @override
  String imageNumberLabel(int index) {
    return 'Bild $index';
  }

  @override
  String downloadNamedImageAction(Object name) {
    return '$name herunterladen';
  }

  @override
  String get stepExpenseDetailsTitle => 'Ausgabendetails';

  @override
  String get stepSubItemsTitle => 'Unterpositionen';

  @override
  String get stepNextAction => 'Weiter';

  @override
  String get stepBackAction => 'Zurück';

  @override
  String get subItemsHelpText =>
      'Füge Positionen vom Beleg hinzu. Eine Ausgabe kann aus mehreren Unterpositionen bestehen.';

  @override
  String get addSubItemAction => 'Unterposition hinzufügen';

  @override
  String get editSubItemAction => 'Unterposition bearbeiten';

  @override
  String get noSubItemsYet => 'Noch keine Unterpositionen hinzugefügt.';

  @override
  String get subItemsTotalLabel => 'Summe Unterpositionen';

  @override
  String subItemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# Unterpositionen',
      one: '# Unterposition',
    );
    return '$_temp0';
  }

  @override
  String secondaryAttachmentsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# Zusatzbilder',
      one: '# Zusatzbild',
    );
    return '$_temp0';
  }

  @override
  String get applySubItemsTotalAction =>
      'Summe der Unterpositionen als Ausgabenbetrag verwenden';

  @override
  String subItemsSumHint(Object amount) {
    return 'Summe Unterpositionen: $amount';
  }

  @override
  String minimumAmountFromSubItemsHint(Object amount) {
    return 'Mindestbetrag basierend auf Unterpositionen: $amount';
  }

  @override
  String pdfTitle(Object account) {
    return '$account';
  }

  @override
  String pdfGeneratedAt(Object date) {
    return 'Erstellt am $date';
  }

  @override
  String get pdfMetaReportIdLabel => 'Report-ID';

  @override
  String get pdfMetaAccountLabel => 'Konto';

  @override
  String get pdfMetaAccountNameLabel => 'Kontobezeichnung';

  @override
  String get pdfMetaPeriodLabel => 'Zeitraum';

  @override
  String get pdfMetaCurrencyLabel => 'Währung';

  @override
  String get pdfMetaGeneratedAtUtcLabel => 'Erstellt um UTC (ISO-8601)';

  @override
  String get pdfMetaSchemaLabel => 'Schema';

  @override
  String get pdfHeaderId => 'ID';

  @override
  String get pdfUnknownId => 'N/V';

  @override
  String get pdfSubItemCategory => 'Unterposition';

  @override
  String get excelSheetExpensesName => 'Ausgaben';

  @override
  String get excelSheetSummaryName => 'Zusammenfassung';

  @override
  String get excelHeaderExpenseId => 'Ausgaben-ID';

  @override
  String get excelHeaderDate => 'Datum';

  @override
  String get excelHeaderCompanyRegisterNumber => 'Firmenbuchnummer';

  @override
  String get excelHeaderVendor => 'Anbieter';

  @override
  String get excelHeaderDescription => 'Beschreibung';

  @override
  String get excelHeaderCategory => 'Kategorie';

  @override
  String get excelHeaderAmountEur => 'Betrag EUR';

  @override
  String get excelHeaderDeductible => 'Absetzbar';

  @override
  String get excelHeaderNotes => 'Notizen';

  @override
  String get excelHeaderSubItemDescription => 'Unterpositionsbeschreibung';

  @override
  String get excelHeaderSubItemAmountEur => 'Unterpositionsbetrag EUR';

  @override
  String get excelSummaryHeaderAccount => 'Konto';

  @override
  String get excelSummaryHeaderEntries => 'Einträge';

  @override
  String get excelSummaryHeaderTotalEur => 'Gesamt EUR';

  @override
  String get excelSummaryHeaderDeductibleEur => 'Absetzbar EUR';

  @override
  String get excelSummaryHeaderNonDeductibleEur => 'Nicht absetzbar EUR';

  @override
  String get excelFileNamePrefix => 'ausgaben_steuerberatung';

  @override
  String get pdfHeaderDate => 'Datum';

  @override
  String get pdfHeaderDescription => 'Beschreibung';

  @override
  String get pdfHeaderVendor => 'Anbieter';

  @override
  String get pdfHeaderCategory => 'Kategorie';

  @override
  String get pdfHeaderAmount => 'Betrag';

  @override
  String get pdfHeaderDeductible => 'Absetzbar';

  @override
  String get pdfHeaderNotes => 'Notizen';

  @override
  String get yesLabel => 'Ja';

  @override
  String get noLabel => 'Nein';

  @override
  String totalLabel(Object amount) {
    return 'Summe: $amount';
  }

  @override
  String deductibleTotalText(Object amount) {
    return 'Absetzbare Summe: $amount';
  }

  @override
  String get categoryPersonalGroceries => 'Lebensmittel';

  @override
  String get categoryPersonalHousehold => 'Haushalt';

  @override
  String get categoryPersonalHealth => 'Gesundheit';

  @override
  String get categoryPersonalMobility => 'Mobilität';

  @override
  String get categoryPersonalEducation => 'Bildung';

  @override
  String get categoryPersonalLeisure => 'Freizeit';

  @override
  String get categoryPersonalOther => 'Sonstiges';

  @override
  String get categoryBusinessOfficeSupplies => 'Bürobedarf';

  @override
  String get categoryBusinessHardware => 'Hardware';

  @override
  String get categoryBusinessSoftware => 'Software';

  @override
  String get categoryBusinessTravel => 'Reisen';

  @override
  String get categoryBusinessTraining => 'Fortbildung';

  @override
  String get categoryBusinessServices => 'Dienstleistungen';

  @override
  String get categoryBusinessOther => 'Sonstiges';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Pilo'**
  String get appTitle;

  /// No description provided for @taxRefundPurchasesTitle.
  ///
  /// In de, this message translates to:
  /// **'Pilo'**
  String get taxRefundPurchasesTitle;

  /// No description provided for @exportPdfTooltip.
  ///
  /// In de, this message translates to:
  /// **'PDF exportieren'**
  String get exportPdfTooltip;

  /// No description provided for @exportSingleExpensePdfTooltip.
  ///
  /// In de, this message translates to:
  /// **'Diese Ausgabe als PDF exportieren'**
  String get exportSingleExpensePdfTooltip;

  /// No description provided for @exportSingleExpensePdfErrorMessage.
  ///
  /// In de, this message translates to:
  /// **'Diese Ausgabe konnte nicht als PDF exportiert werden.'**
  String get exportSingleExpensePdfErrorMessage;

  /// No description provided for @expenseAccountLabel.
  ///
  /// In de, this message translates to:
  /// **'Ausgabenkonto'**
  String get expenseAccountLabel;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontoeinstellungen'**
  String get accountSettingsTitle;

  /// No description provided for @accountDisplayNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Kontobezeichnung'**
  String get accountDisplayNameLabel;

  /// No description provided for @firmenbuchnummerLabel.
  ///
  /// In de, this message translates to:
  /// **'Firmenbuchnummer'**
  String get firmenbuchnummerLabel;

  /// No description provided for @firmenbuchnummerValidation.
  ///
  /// In de, this message translates to:
  /// **'Nur Buchstaben, Zahlen, Leerzeichen, / und - sind erlaubt.'**
  String get firmenbuchnummerValidation;

  /// No description provided for @saveSettingsAction.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen speichern'**
  String get saveSettingsAction;

  /// No description provided for @accountSettingsSavedMessage.
  ///
  /// In de, this message translates to:
  /// **'Kontoeinstellungen gespeichert.'**
  String get accountSettingsSavedMessage;

  /// No description provided for @dataExportTitle.
  ///
  /// In de, this message translates to:
  /// **'Datenexport'**
  String get dataExportTitle;

  /// No description provided for @exportExcelForTaxConsultantAction.
  ///
  /// In de, this message translates to:
  /// **'Excel für die Steuerberatung exportieren'**
  String get exportExcelForTaxConsultantAction;

  /// No description provided for @exportExcelSuccessMessage.
  ///
  /// In de, this message translates to:
  /// **'Excel-Datei ist zum Teilen bereit.'**
  String get exportExcelSuccessMessage;

  /// No description provided for @exportInProgressMessage.
  ///
  /// In de, this message translates to:
  /// **'Export läuft…'**
  String get exportInProgressMessage;

  /// No description provided for @exportDateRangeTitle.
  ///
  /// In de, this message translates to:
  /// **'Exportzeitraum auswählen'**
  String get exportDateRangeTitle;

  /// No description provided for @confirmDateRangeAction.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum verwenden'**
  String get confirmDateRangeAction;

  /// No description provided for @noItemsInDateRangeMessage.
  ///
  /// In de, this message translates to:
  /// **'Im ausgewählten Zeitraum wurden keine Ausgaben gefunden.'**
  String get noItemsInDateRangeMessage;

  /// No description provided for @discardChangesTitle.
  ///
  /// In de, this message translates to:
  /// **'Änderungen verwerfen?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In de, this message translates to:
  /// **'Du hast ungespeicherte Änderungen in diesem Formular.'**
  String get discardChangesMessage;

  /// No description provided for @discardChangesAction.
  ///
  /// In de, this message translates to:
  /// **'Verwerfen'**
  String get discardChangesAction;

  /// No description provided for @selectionCountLabel.
  ///
  /// In de, this message translates to:
  /// **'{count} ausgewählt'**
  String selectionCountLabel(int count);

  /// No description provided for @deleteSelectionTooltip.
  ///
  /// In de, this message translates to:
  /// **'Auswahl löschen'**
  String get deleteSelectionTooltip;

  /// No description provided for @clearSelectionTooltip.
  ///
  /// In de, this message translates to:
  /// **'Auswahl beenden'**
  String get clearSelectionTooltip;

  /// No description provided for @deleteSelectedExpensesTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgewählte Ausgaben löschen?'**
  String get deleteSelectedExpensesTitle;

  /// No description provided for @deleteSelectedExpensesMessage.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{# Eintrag wird gelöscht.} other{# Einträge werden gelöscht.}}'**
  String deleteSelectedExpensesMessage(int count);

  /// No description provided for @subItemsExceedTotalValidation.
  ///
  /// In de, this message translates to:
  /// **'Unterpositionen dürfen nicht höher als der Ausgabenbetrag sein.'**
  String get subItemsExceedTotalValidation;

  /// No description provided for @subItemAmountExceedsTotalValidation.
  ///
  /// In de, this message translates to:
  /// **'Diese Unterposition ist höher als der Ausgabenbetrag.'**
  String get subItemAmountExceedsTotalValidation;

  /// No description provided for @remainingForSubItemsLabel.
  ///
  /// In de, this message translates to:
  /// **'Verbleibend für Unterpositionen'**
  String get remainingForSubItemsLabel;

  /// No description provided for @accountLabelPersonal.
  ///
  /// In de, this message translates to:
  /// **'Private Ausgaben'**
  String get accountLabelPersonal;

  /// No description provided for @accountLabelBusiness.
  ///
  /// In de, this message translates to:
  /// **'Betriebliche Ausgaben'**
  String get accountLabelBusiness;

  /// No description provided for @accountLabelInSentencePersonal.
  ///
  /// In de, this message translates to:
  /// **'private Ausgaben'**
  String get accountLabelInSentencePersonal;

  /// No description provided for @accountLabelInSentenceBusiness.
  ///
  /// In de, this message translates to:
  /// **'betriebliche Ausgaben'**
  String get accountLabelInSentenceBusiness;

  /// No description provided for @addPurchase.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe hinzufügen'**
  String get addPurchase;

  /// No description provided for @addPurchaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe hinzufügen'**
  String get addPurchaseTitle;

  /// No description provided for @editPurchaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe bearbeiten'**
  String get editPurchaseTitle;

  /// No description provided for @editPurchaseAction.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get editPurchaseAction;

  /// No description provided for @savePurchaseAction.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get savePurchaseAction;

  /// No description provided for @deletePurchaseAction.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get deletePurchaseAction;

  /// No description provided for @deletePurchaseTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe löschen?'**
  String get deletePurchaseTitle;

  /// No description provided for @deletePurchaseMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diese Ausgabe wirklich löschen?'**
  String get deletePurchaseMessage;

  /// No description provided for @cancelAction.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancelAction;

  /// No description provided for @confirmDeleteAction.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get confirmDeleteAction;

  /// No description provided for @purchaseDetailsTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgabedetails'**
  String get purchaseDetailsTitle;

  /// No description provided for @descriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get descriptionLabel;

  /// No description provided for @descriptionValidation.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Beschreibung eingeben.'**
  String get descriptionValidation;

  /// No description provided for @vendorLabel.
  ///
  /// In de, this message translates to:
  /// **'Anbieter'**
  String get vendorLabel;

  /// No description provided for @amountLabel.
  ///
  /// In de, this message translates to:
  /// **'Betrag (€)'**
  String get amountLabel;

  /// No description provided for @amountValidation.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Betrag eingeben.'**
  String get amountValidation;

  /// No description provided for @amountInvalidValidation.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen gültigen Betrag eingeben.'**
  String get amountInvalidValidation;

  /// No description provided for @categoryLabel.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get categoryLabel;

  /// No description provided for @dateOfPurchaseLabel.
  ///
  /// In de, this message translates to:
  /// **'Kaufdatum'**
  String get dateOfPurchaseLabel;

  /// No description provided for @pickDate.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get pickDate;

  /// No description provided for @vatDeductibleLabel.
  ///
  /// In de, this message translates to:
  /// **'In Österreich vorsteuerabzugsfähig'**
  String get vatDeductibleLabel;

  /// No description provided for @notesLabel.
  ///
  /// In de, this message translates to:
  /// **'Notizen für die Steuerberatung'**
  String get notesLabel;

  /// No description provided for @addBeforeExport.
  ///
  /// In de, this message translates to:
  /// **'Bitte zuerst Ausgaben hinzufügen, bevor exportiert wird.'**
  String get addBeforeExport;

  /// No description provided for @emptyStateTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben einfach erfassen und organisieren'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Füge jeden Beleg für {account} hinzu, damit du alles übersichtlich an einem Ort hast.'**
  String emptyStateSubtitle(Object account);

  /// No description provided for @dashboardTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Analyse'**
  String get dashboardTabLabel;

  /// No description provided for @expensesTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben'**
  String get expensesTabLabel;

  /// No description provided for @totalAmountLabel.
  ///
  /// In de, this message translates to:
  /// **'Gesamtsumme'**
  String get totalAmountLabel;

  /// No description provided for @averageExpenseLabel.
  ///
  /// In de, this message translates to:
  /// **'Durchschnitt pro Ausgabe'**
  String get averageExpenseLabel;

  /// No description provided for @nonDeductibleTotalLabel.
  ///
  /// In de, this message translates to:
  /// **'Nicht absetzbar'**
  String get nonDeductibleTotalLabel;

  /// No description provided for @topCategoriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Top-Kategorien'**
  String get topCategoriesLabel;

  /// No description provided for @deductibleTotalLabel.
  ///
  /// In de, this message translates to:
  /// **'Absetzbare Summe'**
  String get deductibleTotalLabel;

  /// No description provided for @itemsTracked.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{# Eintrag erfasst} other{# Einträge erfasst}}'**
  String itemsTracked(int count);

  /// No description provided for @unknownVendor.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Anbieter'**
  String get unknownVendor;

  /// No description provided for @deductibleLabel.
  ///
  /// In de, this message translates to:
  /// **'Absetzbar'**
  String get deductibleLabel;

  /// No description provided for @notDeductibleLabel.
  ///
  /// In de, this message translates to:
  /// **'Nicht absetzbar'**
  String get notDeductibleLabel;

  /// No description provided for @offlineOcrPrivacyNote.
  ///
  /// In de, this message translates to:
  /// **'Belege werden offline auf dem Gerät gescannt. Keine Bild- oder Textdaten verlassen dein Gerät.'**
  String get offlineOcrPrivacyNote;

  /// No description provided for @scanReceiptAction.
  ///
  /// In de, this message translates to:
  /// **'Kassenbon scannen'**
  String get scanReceiptAction;

  /// No description provided for @scanDocumentAction.
  ///
  /// In de, this message translates to:
  /// **'A4-Rechnung scannen'**
  String get scanDocumentAction;

  /// No description provided for @ocrNoTextFound.
  ///
  /// In de, this message translates to:
  /// **'Kein lesbarer Text auf dem Beleg gefunden.'**
  String get ocrNoTextFound;

  /// No description provided for @ocrNoTextFoundWithAttachment.
  ///
  /// In de, this message translates to:
  /// **'Kein lesbarer Text auf dem Beleg gefunden. Das Belegfoto wurde angehängt.'**
  String get ocrNoTextFoundWithAttachment;

  /// No description provided for @ocrAppliedMessage.
  ///
  /// In de, this message translates to:
  /// **'Belegdaten wurden in das Formular übernommen.'**
  String get ocrAppliedMessage;

  /// No description provided for @ocrErrorMessage.
  ///
  /// In de, this message translates to:
  /// **'Belegscan fehlgeschlagen. Bitte erneut versuchen.'**
  String get ocrErrorMessage;

  /// No description provided for @imageSaveFailedMessage.
  ///
  /// In de, this message translates to:
  /// **'Bild konnte nicht gespeichert werden.'**
  String get imageSaveFailedMessage;

  /// No description provided for @secondaryImageAddedMessage.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliches Bild hinzugefügt.'**
  String get secondaryImageAddedMessage;

  /// No description provided for @renameImageTitle.
  ///
  /// In de, this message translates to:
  /// **'Bildname ändern'**
  String get renameImageTitle;

  /// No description provided for @nameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @scanFromCameraAction.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get scanFromCameraAction;

  /// No description provided for @scanFromGalleryAction.
  ///
  /// In de, this message translates to:
  /// **'Aus Fotos auswählen'**
  String get scanFromGalleryAction;

  /// No description provided for @receiptAttachedLabel.
  ///
  /// In de, this message translates to:
  /// **'Beleg angehängt'**
  String get receiptAttachedLabel;

  /// No description provided for @scanningReceiptProgress.
  ///
  /// In de, this message translates to:
  /// **'Pilo scannt deinen Beleg{dots}'**
  String scanningReceiptProgress(Object dots);

  /// No description provided for @receiptFileNotFoundMessage.
  ///
  /// In de, this message translates to:
  /// **'Die Belegdatei wurde nicht gefunden.'**
  String get receiptFileNotFoundMessage;

  /// No description provided for @receiptSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Beleg'**
  String get receiptSectionTitle;

  /// No description provided for @downloadReceiptAction.
  ///
  /// In de, this message translates to:
  /// **'Beleg herunterladen'**
  String get downloadReceiptAction;

  /// No description provided for @additionalImagesSectionTitle.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Bilder'**
  String get additionalImagesSectionTitle;

  /// No description provided for @additionalImagesAddAction.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Bilder hinzufügen'**
  String get additionalImagesAddAction;

  /// No description provided for @additionalImagesCountAction.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Bilder ({count})'**
  String additionalImagesCountAction(int count);

  /// No description provided for @renameImageTooltip.
  ///
  /// In de, this message translates to:
  /// **'Namen ändern'**
  String get renameImageTooltip;

  /// No description provided for @moveUpTooltip.
  ///
  /// In de, this message translates to:
  /// **'Nach oben'**
  String get moveUpTooltip;

  /// No description provided for @moveDownTooltip.
  ///
  /// In de, this message translates to:
  /// **'Nach unten'**
  String get moveDownTooltip;

  /// No description provided for @imageNumberLabel.
  ///
  /// In de, this message translates to:
  /// **'Bild {index}'**
  String imageNumberLabel(int index);

  /// No description provided for @downloadNamedImageAction.
  ///
  /// In de, this message translates to:
  /// **'{name} herunterladen'**
  String downloadNamedImageAction(Object name);

  /// No description provided for @stepExpenseDetailsTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgabendetails'**
  String get stepExpenseDetailsTitle;

  /// No description provided for @stepSubItemsTitle.
  ///
  /// In de, this message translates to:
  /// **'Unterpositionen'**
  String get stepSubItemsTitle;

  /// No description provided for @stepNextAction.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get stepNextAction;

  /// No description provided for @stepBackAction.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get stepBackAction;

  /// No description provided for @subItemsHelpText.
  ///
  /// In de, this message translates to:
  /// **'Füge Positionen vom Beleg hinzu. Eine Ausgabe kann aus mehreren Unterpositionen bestehen.'**
  String get subItemsHelpText;

  /// No description provided for @addSubItemAction.
  ///
  /// In de, this message translates to:
  /// **'Unterposition hinzufügen'**
  String get addSubItemAction;

  /// No description provided for @editSubItemAction.
  ///
  /// In de, this message translates to:
  /// **'Unterposition bearbeiten'**
  String get editSubItemAction;

  /// No description provided for @noSubItemsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Unterpositionen hinzugefügt.'**
  String get noSubItemsYet;

  /// No description provided for @subItemsTotalLabel.
  ///
  /// In de, this message translates to:
  /// **'Summe Unterpositionen'**
  String get subItemsTotalLabel;

  /// No description provided for @subItemsCountLabel.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{# Unterposition} other{# Unterpositionen}}'**
  String subItemsCountLabel(int count);

  /// No description provided for @secondaryAttachmentsCountLabel.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{# Zusatzbild} other{# Zusatzbilder}}'**
  String secondaryAttachmentsCountLabel(int count);

  /// No description provided for @applySubItemsTotalAction.
  ///
  /// In de, this message translates to:
  /// **'Summe der Unterpositionen als Ausgabenbetrag verwenden'**
  String get applySubItemsTotalAction;

  /// No description provided for @subItemsSumHint.
  ///
  /// In de, this message translates to:
  /// **'Summe Unterpositionen: {amount}'**
  String subItemsSumHint(Object amount);

  /// No description provided for @minimumAmountFromSubItemsHint.
  ///
  /// In de, this message translates to:
  /// **'Mindestbetrag basierend auf Unterpositionen: {amount}'**
  String minimumAmountFromSubItemsHint(Object amount);

  /// No description provided for @pdfTitle.
  ///
  /// In de, this message translates to:
  /// **'{account}'**
  String pdfTitle(Object account);

  /// No description provided for @pdfGeneratedAt.
  ///
  /// In de, this message translates to:
  /// **'Erstellt am {date}'**
  String pdfGeneratedAt(Object date);

  /// No description provided for @pdfMetaReportIdLabel.
  ///
  /// In de, this message translates to:
  /// **'Report-ID'**
  String get pdfMetaReportIdLabel;

  /// No description provided for @pdfMetaAccountLabel.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get pdfMetaAccountLabel;

  /// No description provided for @pdfMetaAccountNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Kontobezeichnung'**
  String get pdfMetaAccountNameLabel;

  /// No description provided for @pdfMetaPeriodLabel.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum'**
  String get pdfMetaPeriodLabel;

  /// No description provided for @pdfMetaCurrencyLabel.
  ///
  /// In de, this message translates to:
  /// **'Währung'**
  String get pdfMetaCurrencyLabel;

  /// No description provided for @pdfMetaGeneratedAtUtcLabel.
  ///
  /// In de, this message translates to:
  /// **'Erstellt um UTC (ISO-8601)'**
  String get pdfMetaGeneratedAtUtcLabel;

  /// No description provided for @pdfMetaSchemaLabel.
  ///
  /// In de, this message translates to:
  /// **'Schema'**
  String get pdfMetaSchemaLabel;

  /// No description provided for @pdfHeaderId.
  ///
  /// In de, this message translates to:
  /// **'ID'**
  String get pdfHeaderId;

  /// No description provided for @pdfUnknownId.
  ///
  /// In de, this message translates to:
  /// **'N/V'**
  String get pdfUnknownId;

  /// No description provided for @pdfSubItemCategory.
  ///
  /// In de, this message translates to:
  /// **'Unterposition'**
  String get pdfSubItemCategory;

  /// No description provided for @excelSheetExpensesName.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben'**
  String get excelSheetExpensesName;

  /// No description provided for @excelSheetSummaryName.
  ///
  /// In de, this message translates to:
  /// **'Zusammenfassung'**
  String get excelSheetSummaryName;

  /// No description provided for @excelHeaderExpenseId.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben-ID'**
  String get excelHeaderExpenseId;

  /// No description provided for @excelHeaderDate.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get excelHeaderDate;

  /// No description provided for @excelHeaderCompanyRegisterNumber.
  ///
  /// In de, this message translates to:
  /// **'Firmenbuchnummer'**
  String get excelHeaderCompanyRegisterNumber;

  /// No description provided for @excelHeaderVendor.
  ///
  /// In de, this message translates to:
  /// **'Anbieter'**
  String get excelHeaderVendor;

  /// No description provided for @excelHeaderDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get excelHeaderDescription;

  /// No description provided for @excelHeaderCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get excelHeaderCategory;

  /// No description provided for @excelHeaderAmountEur.
  ///
  /// In de, this message translates to:
  /// **'Betrag EUR'**
  String get excelHeaderAmountEur;

  /// No description provided for @excelHeaderDeductible.
  ///
  /// In de, this message translates to:
  /// **'Absetzbar'**
  String get excelHeaderDeductible;

  /// No description provided for @excelHeaderNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get excelHeaderNotes;

  /// No description provided for @excelHeaderSubItemDescription.
  ///
  /// In de, this message translates to:
  /// **'Unterpositionsbeschreibung'**
  String get excelHeaderSubItemDescription;

  /// No description provided for @excelHeaderSubItemAmountEur.
  ///
  /// In de, this message translates to:
  /// **'Unterpositionsbetrag EUR'**
  String get excelHeaderSubItemAmountEur;

  /// No description provided for @excelSummaryHeaderAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get excelSummaryHeaderAccount;

  /// No description provided for @excelSummaryHeaderEntries.
  ///
  /// In de, this message translates to:
  /// **'Einträge'**
  String get excelSummaryHeaderEntries;

  /// No description provided for @excelSummaryHeaderTotalEur.
  ///
  /// In de, this message translates to:
  /// **'Gesamt EUR'**
  String get excelSummaryHeaderTotalEur;

  /// No description provided for @excelSummaryHeaderDeductibleEur.
  ///
  /// In de, this message translates to:
  /// **'Absetzbar EUR'**
  String get excelSummaryHeaderDeductibleEur;

  /// No description provided for @excelSummaryHeaderNonDeductibleEur.
  ///
  /// In de, this message translates to:
  /// **'Nicht absetzbar EUR'**
  String get excelSummaryHeaderNonDeductibleEur;

  /// No description provided for @excelFileNamePrefix.
  ///
  /// In de, this message translates to:
  /// **'ausgaben_steuerberatung'**
  String get excelFileNamePrefix;

  /// No description provided for @pdfHeaderDate.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get pdfHeaderDate;

  /// No description provided for @pdfHeaderDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get pdfHeaderDescription;

  /// No description provided for @pdfHeaderVendor.
  ///
  /// In de, this message translates to:
  /// **'Anbieter'**
  String get pdfHeaderVendor;

  /// No description provided for @pdfHeaderCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get pdfHeaderCategory;

  /// No description provided for @pdfHeaderAmount.
  ///
  /// In de, this message translates to:
  /// **'Betrag'**
  String get pdfHeaderAmount;

  /// No description provided for @pdfHeaderDeductible.
  ///
  /// In de, this message translates to:
  /// **'Absetzbar'**
  String get pdfHeaderDeductible;

  /// No description provided for @pdfHeaderNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get pdfHeaderNotes;

  /// No description provided for @yesLabel.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get noLabel;

  /// No description provided for @totalLabel.
  ///
  /// In de, this message translates to:
  /// **'Summe: {amount}'**
  String totalLabel(Object amount);

  /// No description provided for @deductibleTotalText.
  ///
  /// In de, this message translates to:
  /// **'Absetzbare Summe: {amount}'**
  String deductibleTotalText(Object amount);

  /// No description provided for @categoryPersonalGroceries.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel'**
  String get categoryPersonalGroceries;

  /// No description provided for @categoryPersonalHousehold.
  ///
  /// In de, this message translates to:
  /// **'Haushalt'**
  String get categoryPersonalHousehold;

  /// No description provided for @categoryPersonalHealth.
  ///
  /// In de, this message translates to:
  /// **'Gesundheit'**
  String get categoryPersonalHealth;

  /// No description provided for @categoryPersonalMobility.
  ///
  /// In de, this message translates to:
  /// **'Mobilität'**
  String get categoryPersonalMobility;

  /// No description provided for @categoryPersonalEducation.
  ///
  /// In de, this message translates to:
  /// **'Bildung'**
  String get categoryPersonalEducation;

  /// No description provided for @categoryPersonalLeisure.
  ///
  /// In de, this message translates to:
  /// **'Freizeit'**
  String get categoryPersonalLeisure;

  /// No description provided for @categoryPersonalOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categoryPersonalOther;

  /// No description provided for @categoryBusinessOfficeSupplies.
  ///
  /// In de, this message translates to:
  /// **'Bürobedarf'**
  String get categoryBusinessOfficeSupplies;

  /// No description provided for @categoryBusinessHardware.
  ///
  /// In de, this message translates to:
  /// **'Hardware'**
  String get categoryBusinessHardware;

  /// No description provided for @categoryBusinessSoftware.
  ///
  /// In de, this message translates to:
  /// **'Software'**
  String get categoryBusinessSoftware;

  /// No description provided for @categoryBusinessTravel.
  ///
  /// In de, this message translates to:
  /// **'Reisen'**
  String get categoryBusinessTravel;

  /// No description provided for @categoryBusinessTraining.
  ///
  /// In de, this message translates to:
  /// **'Fortbildung'**
  String get categoryBusinessTraining;

  /// No description provided for @categoryBusinessServices.
  ///
  /// In de, this message translates to:
  /// **'Dienstleistungen'**
  String get categoryBusinessServices;

  /// No description provided for @categoryBusinessOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get categoryBusinessOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

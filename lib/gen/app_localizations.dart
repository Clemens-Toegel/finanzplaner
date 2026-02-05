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
  /// **'Steuererstattungs-Ausgaben'**
  String get appTitle;

  /// No description provided for @taxRefundPurchasesTitle.
  ///
  /// In de, this message translates to:
  /// **'Steuererstattungs-Ausgaben'**
  String get taxRefundPurchasesTitle;

  /// No description provided for @exportPdfTooltip.
  ///
  /// In de, this message translates to:
  /// **'PDF exportieren'**
  String get exportPdfTooltip;

  /// No description provided for @expenseAccountLabel.
  ///
  /// In de, this message translates to:
  /// **'Ausgabenkonto'**
  String get expenseAccountLabel;

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
  /// **'Steuerlich absetzbare Ausgaben in Österreich erfassen'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Füge jeden Beleg für {account} hinzu, damit deine Steuerberatung ihn prüfen kann.'**
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

  /// No description provided for @pdfTitle.
  ///
  /// In de, this message translates to:
  /// **'{account} – absetzbare Ausgaben'**
  String pdfTitle(Object account);

  /// No description provided for @pdfGeneratedAt.
  ///
  /// In de, this message translates to:
  /// **'Erstellt am {date}'**
  String pdfGeneratedAt(Object date);

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

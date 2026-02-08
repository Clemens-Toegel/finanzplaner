// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BelegPilot';

  @override
  String get taxRefundPurchasesTitle => 'BelegPilot';

  @override
  String get exportPdfTooltip => 'Export PDF';

  @override
  String get expenseAccountLabel => 'Expense account';

  @override
  String get accountSettingsTitle => 'Account settings';

  @override
  String get accountDisplayNameLabel => 'Account display name';

  @override
  String get firmenbuchnummerLabel => 'Firmenbuchnummer';

  @override
  String get firmenbuchnummerValidation =>
      'Only letters, numbers, spaces, / and - are allowed.';

  @override
  String get saveSettingsAction => 'Save settings';

  @override
  String get accountSettingsSavedMessage => 'Account settings saved.';

  @override
  String get dataExportTitle => 'Data export';

  @override
  String get exportExcelForTaxConsultantAction =>
      'Export Excel for tax consultant';

  @override
  String get exportExcelSuccessMessage => 'Excel file is ready to share.';

  @override
  String get exportInProgressMessage => 'Export in progress…';

  @override
  String get exportDateRangeTitle => 'Select export period';

  @override
  String get confirmDateRangeAction => 'Use range';

  @override
  String get noItemsInDateRangeMessage =>
      'No expenses found in the selected date range.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'You have unsaved changes in this form.';

  @override
  String get discardChangesAction => 'Discard';

  @override
  String selectionCountLabel(int count) {
    return '$count selected';
  }

  @override
  String get deleteSelectionTooltip => 'Delete selection';

  @override
  String get clearSelectionTooltip => 'End selection';

  @override
  String get deleteSelectedExpensesTitle => 'Delete selected expenses?';

  @override
  String deleteSelectedExpensesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# entries will be deleted.',
      one: '# entry will be deleted.',
    );
    return '$_temp0';
  }

  @override
  String get subItemsExceedTotalValidation =>
      'Sub-items cannot be higher than the expense total.';

  @override
  String get subItemAmountExceedsTotalValidation =>
      'This sub-item is higher than the expense total.';

  @override
  String get remainingForSubItemsLabel => 'Remaining for sub-items';

  @override
  String get accountLabelPersonal => 'Personal expenses';

  @override
  String get accountLabelBusiness => 'Business expenses';

  @override
  String get accountLabelInSentencePersonal => 'personal expenses';

  @override
  String get accountLabelInSentenceBusiness => 'business expenses';

  @override
  String get addPurchase => 'Add expense';

  @override
  String get addPurchaseTitle => 'Add expense';

  @override
  String get editPurchaseTitle => 'Edit expense';

  @override
  String get editPurchaseAction => 'Edit';

  @override
  String get savePurchaseAction => 'Save';

  @override
  String get deletePurchaseAction => 'Delete';

  @override
  String get deletePurchaseTitle => 'Delete expense?';

  @override
  String get deletePurchaseMessage =>
      'Do you really want to delete this expense?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get confirmDeleteAction => 'Delete';

  @override
  String get purchaseDetailsTitle => 'Expense details';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionValidation => 'Please enter a description.';

  @override
  String get vendorLabel => 'Vendor';

  @override
  String get amountLabel => 'Amount (€)';

  @override
  String get amountValidation => 'Please enter an amount.';

  @override
  String get amountInvalidValidation => 'Please enter a valid amount.';

  @override
  String get categoryLabel => 'Category';

  @override
  String get dateOfPurchaseLabel => 'Purchase date';

  @override
  String get pickDate => 'Select';

  @override
  String get vatDeductibleLabel => 'VAT deductible in Austria';

  @override
  String get notesLabel => 'Notes for tax advisor';

  @override
  String get addBeforeExport => 'Please add expenses before exporting.';

  @override
  String get emptyStateTitle => 'Capture and organize expenses with ease';

  @override
  String emptyStateSubtitle(Object account) {
    return 'Add each receipt for $account to keep everything clearly organized in one place.';
  }

  @override
  String get dashboardTabLabel => 'Analytics';

  @override
  String get expensesTabLabel => 'Expenses';

  @override
  String get totalAmountLabel => 'Total amount';

  @override
  String get averageExpenseLabel => 'Average expense';

  @override
  String get nonDeductibleTotalLabel => 'Not deductible';

  @override
  String get topCategoriesLabel => 'Top categories';

  @override
  String get deductibleTotalLabel => 'Deductible total';

  @override
  String itemsTracked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# items tracked',
      one: '# item tracked',
    );
    return '$_temp0';
  }

  @override
  String get unknownVendor => 'Unknown vendor';

  @override
  String get deductibleLabel => 'Deductible';

  @override
  String get notDeductibleLabel => 'Not deductible';

  @override
  String get offlineOcrPrivacyNote =>
      'Scan bills offline on-device. No image or text leaves your phone.';

  @override
  String get scanReceiptAction => 'Scan receipt';

  @override
  String get scanDocumentAction => 'Scan A4 bill';

  @override
  String get ocrNoTextFound => 'No readable text found on the bill.';

  @override
  String get ocrNoTextFoundWithAttachment =>
      'No readable text found on the bill. The receipt image was attached.';

  @override
  String get ocrAppliedMessage => 'Bill data was inserted into the form.';

  @override
  String get ocrErrorMessage => 'Bill scan failed. Please try again.';

  @override
  String get imageSaveFailedMessage => 'Image could not be saved.';

  @override
  String get secondaryImageAddedMessage => 'Additional image added.';

  @override
  String get renameImageTitle => 'Rename image';

  @override
  String get nameLabel => 'Name';

  @override
  String get scanFromCameraAction => 'Take photo';

  @override
  String get scanFromGalleryAction => 'Choose from photos';

  @override
  String get receiptAttachedLabel => 'Receipt attached';

  @override
  String scanningReceiptProgress(Object dots) {
    return 'Pilo is scanning your receipt$dots';
  }

  @override
  String get receiptFileNotFoundMessage =>
      'The receipt file could not be found.';

  @override
  String get receiptSectionTitle => 'Receipt';

  @override
  String get downloadReceiptAction => 'Download receipt';

  @override
  String get additionalImagesSectionTitle => 'Additional images';

  @override
  String get additionalImagesAddAction => 'Add additional images';

  @override
  String additionalImagesCountAction(int count) {
    return 'Additional images ($count)';
  }

  @override
  String get renameImageTooltip => 'Rename';

  @override
  String get moveUpTooltip => 'Move up';

  @override
  String get moveDownTooltip => 'Move down';

  @override
  String imageNumberLabel(int index) {
    return 'Image $index';
  }

  @override
  String downloadNamedImageAction(Object name) {
    return 'Download $name';
  }

  @override
  String get stepExpenseDetailsTitle => 'Expense details';

  @override
  String get stepSubItemsTitle => 'Sub-items';

  @override
  String get stepNextAction => 'Next';

  @override
  String get stepBackAction => 'Back';

  @override
  String get subItemsHelpText =>
      'Add line items from the bill. The expense can be composed of multiple sub-items.';

  @override
  String get addSubItemAction => 'Add sub-item';

  @override
  String get editSubItemAction => 'Edit sub-item';

  @override
  String get noSubItemsYet => 'No sub-items added yet.';

  @override
  String get subItemsTotalLabel => 'Sub-items total';

  @override
  String subItemsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# sub-items',
      one: '# sub-item',
    );
    return '$_temp0';
  }

  @override
  String secondaryAttachmentsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# additional images',
      one: '# additional image',
    );
    return '$_temp0';
  }

  @override
  String get applySubItemsTotalAction =>
      'Use sub-items total as expense amount';

  @override
  String subItemsSumHint(Object amount) {
    return 'Sub-items sum: $amount';
  }

  @override
  String minimumAmountFromSubItemsHint(Object amount) {
    return 'Minimum amount based on sub-items: $amount';
  }

  @override
  String pdfTitle(Object account) {
    return '$account';
  }

  @override
  String pdfGeneratedAt(Object date) {
    return 'Generated on $date';
  }

  @override
  String get pdfMetaReportIdLabel => 'Report ID';

  @override
  String get pdfMetaAccountLabel => 'Account';

  @override
  String get pdfMetaAccountNameLabel => 'Account name';

  @override
  String get pdfMetaPeriodLabel => 'Period';

  @override
  String get pdfMetaCurrencyLabel => 'Currency';

  @override
  String get pdfMetaGeneratedAtUtcLabel => 'Generated at UTC (ISO-8601)';

  @override
  String get pdfMetaSchemaLabel => 'Schema';

  @override
  String get pdfHeaderId => 'ID';

  @override
  String get pdfUnknownId => 'N/A';

  @override
  String get pdfSubItemCategory => 'Sub-item';

  @override
  String get excelSheetExpensesName => 'Expenses';

  @override
  String get excelSheetSummaryName => 'Summary';

  @override
  String get excelHeaderExpenseId => 'Expense ID';

  @override
  String get excelHeaderDate => 'Date';

  @override
  String get excelHeaderCompanyRegisterNumber => 'Company Register Number';

  @override
  String get excelHeaderVendor => 'Vendor';

  @override
  String get excelHeaderDescription => 'Description';

  @override
  String get excelHeaderCategory => 'Category';

  @override
  String get excelHeaderAmountEur => 'Amount EUR';

  @override
  String get excelHeaderDeductible => 'Deductible';

  @override
  String get excelHeaderNotes => 'Notes';

  @override
  String get excelHeaderSubItemDescription => 'Sub-item Description';

  @override
  String get excelHeaderSubItemAmountEur => 'Sub-item Amount EUR';

  @override
  String get excelSummaryHeaderAccount => 'Account';

  @override
  String get excelSummaryHeaderEntries => 'Entries';

  @override
  String get excelSummaryHeaderTotalEur => 'Total EUR';

  @override
  String get excelSummaryHeaderDeductibleEur => 'Deductible EUR';

  @override
  String get excelSummaryHeaderNonDeductibleEur => 'Non-deductible EUR';

  @override
  String get excelFileNamePrefix => 'expenses_tax_consultant';

  @override
  String get pdfHeaderDate => 'Date';

  @override
  String get pdfHeaderDescription => 'Description';

  @override
  String get pdfHeaderVendor => 'Vendor';

  @override
  String get pdfHeaderCategory => 'Category';

  @override
  String get pdfHeaderAmount => 'Amount';

  @override
  String get pdfHeaderDeductible => 'Deductible';

  @override
  String get pdfHeaderNotes => 'Notes';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String totalLabel(Object amount) {
    return 'Total: $amount';
  }

  @override
  String deductibleTotalText(Object amount) {
    return 'Deductible total: $amount';
  }

  @override
  String get categoryPersonalGroceries => 'Groceries';

  @override
  String get categoryPersonalHousehold => 'Household';

  @override
  String get categoryPersonalHealth => 'Health';

  @override
  String get categoryPersonalMobility => 'Mobility';

  @override
  String get categoryPersonalEducation => 'Education';

  @override
  String get categoryPersonalLeisure => 'Leisure';

  @override
  String get categoryPersonalOther => 'Other';

  @override
  String get categoryBusinessOfficeSupplies => 'Office supplies';

  @override
  String get categoryBusinessHardware => 'Hardware';

  @override
  String get categoryBusinessSoftware => 'Software';

  @override
  String get categoryBusinessTravel => 'Travel';

  @override
  String get categoryBusinessTraining => 'Training';

  @override
  String get categoryBusinessServices => 'Services';

  @override
  String get categoryBusinessOther => 'Other';
}

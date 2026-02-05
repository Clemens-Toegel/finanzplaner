// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tax refund expenses';

  @override
  String get taxRefundPurchasesTitle => 'Tax refund expenses';

  @override
  String get exportPdfTooltip => 'Export PDF';

  @override
  String get expenseAccountLabel => 'Expense account';

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
  String get emptyStateTitle => 'Track tax-deductible expenses in Austria';

  @override
  String emptyStateSubtitle(Object account) {
    return 'Add each receipt for $account so your tax advisor can review it.';
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
  String pdfTitle(Object account) {
    return '$account – deductible expenses';
  }

  @override
  String pdfGeneratedAt(Object date) {
    return 'Generated on $date';
  }

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

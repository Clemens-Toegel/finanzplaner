import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../gen/app_localizations.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';
import '../services/excel_exporter.dart';
import '../services/offline_bill_ocr_service.dart';
import '../services/purchase_home_service.dart';

class PurchaseHomeController extends ChangeNotifier {
  PurchaseHomeController({
    PurchaseHomeService? service,
    OfflineBillOcrService? offlineBillOcrService,
    ExcelExporter? excelExporter,
  }) : _service = service ?? DefaultPurchaseHomeService(),
       _offlineBillOcrService =
           offlineBillOcrService ?? OfflineBillOcrService(),
       _excelExporter = excelExporter ?? ExcelExporter();

  final PurchaseHomeService _service;
  final OfflineBillOcrService _offlineBillOcrService;
  final ExcelExporter _excelExporter;

  final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'de_AT',
    symbol: '€',
  );

  ExpenseAccountType selectedAccount = ExpenseAccountType.business;
  List<PurchaseItem> items = [];
  bool isLoading = true;
  bool isExporting = false;
  int selectedTabIndex = 0;
  Map<ExpenseAccountType, AccountSettings> accountSettings = {
    ExpenseAccountType.personal: const AccountSettings(
      accountType: ExpenseAccountType.personal,
    ),
    ExpenseAccountType.business: const AccountSettings(
      accountType: ExpenseAccountType.business,
    ),
  };

  double get totalAmount => items.fold(0, (total, item) => total + item.amount);

  double get deductibleAmount => items
      .where((item) => item.isDeductible)
      .fold(0, (total, item) => total + item.amount);

  double get nonDeductibleAmount => totalAmount - deductibleAmount;

  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final item in items) {
      totals.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    return totals;
  }

  OfflineBillOcrService get offlineBillOcrService => _offlineBillOcrService;

  Future<void> initialize() async {
    await loadAccountSettings();
    await loadItems();
  }

  Future<void> loadItems() async {
    isLoading = true;
    notifyListeners();
    final loadedItems = await _service.fetchPurchases(selectedAccount);
    items = _sortItemsByDate(loadedItems);
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadAccountSettings() async {
    accountSettings = await _service.fetchAccountSettings();
    notifyListeners();
  }

  Future<void> changeAccount(ExpenseAccountType account) async {
    if (selectedAccount == account) {
      return;
    }
    selectedAccount = account;
    notifyListeners();
    await loadItems();
  }

  void changeTab(int index) {
    if (selectedTabIndex == index) {
      return;
    }
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> exportPdf(AppLocalizations localizations) async {
    if (isExporting) {
      return;
    }

    isExporting = true;
    notifyListeners();
    try {
      await _service.exportPdf(
        account: selectedAccount,
        items: items,
        localizations: localizations,
        accountSettings: accountSettings[selectedAccount],
      );
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<bool> exportExcelForTaxConsultant(
    AppLocalizations localizations,
  ) async {
    if (isExporting) {
      return false;
    }

    isExporting = true;
    notifyListeners();
    try {
      final accountItems = await _service.fetchPurchases(selectedAccount);
      if (accountItems.isEmpty) {
        return false;
      }

      await _excelExporter.exportForTaxConsultant(
        account: selectedAccount,
        items: accountItems,
        accountSettings: accountSettings[selectedAccount],
        localizations: localizations,
      );
      return true;
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<void> saveAccountSettings(
    Map<ExpenseAccountType, AccountSettings> settings,
  ) async {
    await _service.saveAccountSettings(settings);
    accountSettings = settings;
    notifyListeners();
  }

  Future<void> savePurchaseDraft(PurchaseItem draft) async {
    if (draft.id == null) {
      final savedItem = await _service.insertPurchase(draft);
      items = _sortItemsByDate([savedItem, ...items]);
      notifyListeners();
      return;
    }

    await _service.updatePurchase(draft);
    final index = items.indexWhere((existing) => existing.id == draft.id);
    if (index != -1) {
      items = _sortItemsByDate(List.from(items)..[index] = draft);
      notifyListeners();
    }
  }

  Future<void> deletePurchase(int id) async {
    await _service.deletePurchase(id);
    items = items.where((existing) => existing.id != id).toList();
    notifyListeners();
  }

  List<PurchaseItem> _sortItemsByDate(List<PurchaseItem> unsorted) {
    final sorted = List<PurchaseItem>.from(unsorted)
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) {
          return byDate;
        }
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return sorted;
  }

  @override
  void dispose() {
    unawaited(_offlineBillOcrService.dispose().catchError((_) {}));
    super.dispose();
  }
}

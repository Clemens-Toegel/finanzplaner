import 'dart:async';

import 'package:flutter/material.dart';
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
  Set<int> selectedPurchaseIds = <int>{};
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

  bool get isSelectionMode => selectedPurchaseIds.isNotEmpty;

  Future<void> initialize() async {
    await loadAccountSettings();
    await loadItems();
  }

  Future<void> loadItems() async {
    isLoading = true;
    selectedPurchaseIds.clear();
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
    if (index != 0) {
      selectedPurchaseIds.clear();
    }
    notifyListeners();
  }

  void togglePurchaseSelection(PurchaseItem item) {
    final id = item.id;
    if (id == null) {
      return;
    }
    if (selectedPurchaseIds.contains(id)) {
      selectedPurchaseIds.remove(id);
    } else {
      selectedPurchaseIds.add(id);
    }
    notifyListeners();
  }

  bool isPurchaseSelected(PurchaseItem item) {
    final id = item.id;
    if (id == null) {
      return false;
    }
    return selectedPurchaseIds.contains(id);
  }

  void clearSelection() {
    if (selectedPurchaseIds.isEmpty) {
      return;
    }
    selectedPurchaseIds.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedPurchases() async {
    final ids = Set<int>.from(selectedPurchaseIds);
    if (ids.isEmpty) {
      return;
    }

    final selectedItems = items.where((item) {
      final id = item.id;
      return id != null && ids.contains(id);
    }).toList();

    for (final item in selectedItems) {
      await _service.deletePurchase(item);
      await _offlineBillOcrService.deleteStoredAttachment(item.attachmentPath);
      for (final path in item.secondaryAttachmentPaths) {
        await _offlineBillOcrService.deleteStoredAttachment(path);
      }
    }

    items = items.where((item) {
      final id = item.id;
      return id == null || !ids.contains(id);
    }).toList();
    selectedPurchaseIds.clear();
    notifyListeners();
  }

  Future<bool> exportPdf(
    AppLocalizations localizations, {
    required DateTimeRange dateRange,
  }) async {
    if (isExporting) {
      return false;
    }

    final filteredItems = _filterItemsByDateRange(items, dateRange);
    if (filteredItems.isEmpty) {
      return false;
    }

    isExporting = true;
    notifyListeners();
    try {
      await _service.exportPdf(
        account: selectedAccount,
        items: filteredItems,
        localizations: localizations,
        accountSettings: accountSettings[selectedAccount],
      );
      return true;
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<bool> exportExcelForTaxConsultant(
    AppLocalizations localizations, {
    required DateTimeRange dateRange,
  }) async {
    if (isExporting) {
      return false;
    }

    isExporting = true;
    notifyListeners();
    try {
      final accountItems = await _service.fetchPurchases(selectedAccount);
      final filteredItems = _filterItemsByDateRange(accountItems, dateRange);
      if (filteredItems.isEmpty) {
        return false;
      }

      await _excelExporter.exportForTaxConsultant(
        account: selectedAccount,
        items: filteredItems,
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

    final index = items.indexWhere((existing) => existing.id == draft.id);
    final previous = index != -1 ? items[index] : null;

    await _service.updatePurchase(draft);

    final previousAttachment = previous?.attachmentPath?.trim() ?? '';
    final nextAttachment = draft.attachmentPath?.trim() ?? '';
    if (previousAttachment.isNotEmpty && previousAttachment != nextAttachment) {
      await _offlineBillOcrService.deleteStoredAttachment(previousAttachment);
    }

    final previousSecondary = previous?.secondaryAttachmentPaths ?? const [];
    final nextSecondary = draft.secondaryAttachmentPaths;
    final removedSecondary = previousSecondary
        .where((path) => !nextSecondary.contains(path))
        .toList();
    for (final path in removedSecondary) {
      await _offlineBillOcrService.deleteStoredAttachment(path);
    }

    if (index != -1) {
      items = _sortItemsByDate(List.from(items)..[index] = draft);
      notifyListeners();
    }
  }

  Future<void> deletePurchase(PurchaseItem item) async {
    await _service.deletePurchase(item);
    await _offlineBillOcrService.deleteStoredAttachment(item.attachmentPath);
    for (final path in item.secondaryAttachmentPaths) {
      await _offlineBillOcrService.deleteStoredAttachment(path);
    }
    final id = item.id;
    if (id == null) {
      return;
    }
    selectedPurchaseIds.remove(id);
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

  List<PurchaseItem> _filterItemsByDateRange(
    List<PurchaseItem> source,
    DateTimeRange dateRange,
  ) {
    final start = DateTime(
      dateRange.start.year,
      dateRange.start.month,
      dateRange.start.day,
    );
    final end = DateTime(
      dateRange.end.year,
      dateRange.end.month,
      dateRange.end.day,
      23,
      59,
      59,
      999,
    );

    return source
        .where((item) => !item.date.isBefore(start) && !item.date.isAfter(end))
        .toList();
  }

  @override
  void dispose() {
    unawaited(_offlineBillOcrService.dispose().catchError((_) {}));
    super.dispose();
  }
}

import '../data/purchase_repository.dart';
import '../gen/app_localizations.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';
import 'pdf_exporter.dart';

abstract class PurchaseHomeService {
  Future<List<PurchaseItem>> fetchPurchases(ExpenseAccountType account);
  Future<Map<ExpenseAccountType, AccountSettings>> fetchAccountSettings();
  Future<void> saveAccountSettings(
    Map<ExpenseAccountType, AccountSettings> settings,
  );
  Future<PurchaseItem> insertPurchase(PurchaseItem item);
  Future<PurchaseItem> updatePurchase(PurchaseItem item);
  Future<void> deletePurchase(int id);
  Future<void> exportPdf({
    required ExpenseAccountType account,
    required List<PurchaseItem> items,
    required AppLocalizations localizations,
    required AccountSettings? accountSettings,
  });
}

class DefaultPurchaseHomeService implements PurchaseHomeService {
  DefaultPurchaseHomeService({
    PurchaseRepository? repository,
    PdfExporter? pdfExporter,
  }) : _repository = repository ?? PurchaseRepository(),
       _pdfExporter = pdfExporter ?? PdfExporter();

  final PurchaseRepository _repository;
  final PdfExporter _pdfExporter;

  @override
  Future<List<PurchaseItem>> fetchPurchases(ExpenseAccountType account) {
    return _repository.fetchPurchases(account);
  }

  @override
  Future<Map<ExpenseAccountType, AccountSettings>> fetchAccountSettings() {
    return _repository.fetchAccountSettings();
  }

  @override
  Future<void> saveAccountSettings(
    Map<ExpenseAccountType, AccountSettings> settings,
  ) async {
    await _repository.saveAccountSettings(
      settings[ExpenseAccountType.personal]!,
    );
    await _repository.saveAccountSettings(
      settings[ExpenseAccountType.business]!,
    );
  }

  @override
  Future<PurchaseItem> insertPurchase(PurchaseItem item) {
    return _repository.insertPurchase(item);
  }

  @override
  Future<PurchaseItem> updatePurchase(PurchaseItem item) {
    return _repository.updatePurchase(item);
  }

  @override
  Future<void> deletePurchase(int id) {
    return _repository.deletePurchase(id);
  }

  @override
  Future<void> exportPdf({
    required ExpenseAccountType account,
    required List<PurchaseItem> items,
    required AppLocalizations localizations,
    required AccountSettings? accountSettings,
  }) {
    return _pdfExporter.exportPurchases(
      account: account,
      items: items,
      localizations: localizations,
      accountSettings: accountSettings,
    );
  }
}

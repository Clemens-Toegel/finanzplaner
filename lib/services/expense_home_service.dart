import '../data/expense_repository.dart';
import '../gen/app_localizations.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/expense_item.dart';
import 'pdf_exporter.dart';

abstract class PiloHomeService {
  Future<List<ExpenseItem>> fetchExpenses(ExpenseAccountType account);

  Future<Map<ExpenseAccountType, AccountSettings>> fetchAccountSettings();

  Future<void> saveAccountSettings(
    Map<ExpenseAccountType, AccountSettings> settings,
  );

  Future<ExpenseItem> insertExpense(ExpenseItem item);

  Future<ExpenseItem> updateExpense(ExpenseItem item);

  Future<void> deleteExpense(ExpenseItem item);

  Future<void> exportPdf({
    required ExpenseAccountType account,
    required List<ExpenseItem> items,
    required AppLocalizations localizations,
    required AccountSettings? accountSettings,
  });
}

class DefaultExpenseHomeService implements PiloHomeService {
  DefaultExpenseHomeService({
    ExpenseRepository? repository,
    PdfExporter? pdfExporter,
  }) : _repository = repository ?? ExpenseRepository(),
       _pdfExporter = pdfExporter ?? PdfExporter();

  final ExpenseRepository _repository;
  final PdfExporter _pdfExporter;

  @override
  Future<List<ExpenseItem>> fetchExpenses(ExpenseAccountType account) {
    return _repository.fetchExpenses(account);
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
  Future<ExpenseItem> insertExpense(ExpenseItem item) {
    return _repository.insertExpense(item);
  }

  @override
  Future<ExpenseItem> updateExpense(ExpenseItem item) {
    return _repository.updateExpense(item);
  }

  @override
  Future<void> deleteExpense(ExpenseItem item) {
    final id = item.id;
    if (id == null) {
      return Future.value();
    }
    return _repository.deleteExpenses(id);
  }

  @override
  Future<void> exportPdf({
    required ExpenseAccountType account,
    required List<ExpenseItem> items,
    required AppLocalizations localizations,
    required AccountSettings? accountSettings,
  }) {
    return _pdfExporter.exportExpenses(
      account: account,
      items: items,
      localizations: localizations,
      accountSettings: accountSettings,
    );
  }
}

import 'dart:typed_data';
import 'dart:ui';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../gen/app_localizations.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';

class ExcelExporter {
  Future<void> exportForTaxConsultant({
    required ExpenseAccountType account,
    required List<PurchaseItem> items,
    required AccountSettings? accountSettings,
    required AppLocalizations localizations,
    required Rect sharePositionOrigin,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final localeName = localizations.localeName;
    final dateFormat = DateFormat('yyyy-MM-dd', localeName);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final excel = Excel.createExcel();
    final expensesSheet = excel['Expenses'];
    final summarySheet = excel['Summary'];

    expensesSheet.appendRow([
      TextCellValue('Expense ID'),
      TextCellValue('Date'),
      TextCellValue('Company Register Number'),
      TextCellValue('Vendor'),
      TextCellValue('Description'),
      TextCellValue('Category'),
      TextCellValue('Amount EUR'),
      TextCellValue('Deductible'),
      TextCellValue('Notes'),
      TextCellValue('Sub-item Description'),
      TextCellValue('Sub-item Amount EUR'),
    ]);

    final sorted = List<PurchaseItem>.from(items)
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) {
          return byDate;
        }
        return (a.id ?? 0).compareTo(b.id ?? 0);
      });

    for (final item in sorted) {
      final hasSubItems = item.subItems.isNotEmpty;

      if (!hasSubItems) {
        expensesSheet.appendRow([
          TextCellValue(item.id?.toString() ?? ''),
          TextCellValue(dateFormat.format(item.date)),
          TextCellValue(accountSettings?.companyRegisterNumber ?? ''),
          TextCellValue(item.vendor),
          TextCellValue(item.description),
          TextCellValue(item.category),
          TextCellValue(item.amount.toStringAsFixed(2)),
          TextCellValue(item.isDeductible ? 'Yes' : 'No'),
          TextCellValue(item.notes),
          TextCellValue(''),
          TextCellValue(''),
        ]);
        continue;
      }

      for (final subItem in item.subItems) {
        expensesSheet.appendRow([
          TextCellValue(item.id?.toString() ?? ''),
          TextCellValue(dateFormat.format(item.date)),
          TextCellValue(accountSettings?.companyRegisterNumber ?? ''),
          TextCellValue(item.vendor),
          TextCellValue(item.description),
          TextCellValue(item.category),
          TextCellValue(item.amount.toStringAsFixed(2)),
          TextCellValue(item.isDeductible ? 'Yes' : 'No'),
          TextCellValue(item.notes),
          TextCellValue(subItem.description),
          TextCellValue(subItem.amount.toStringAsFixed(2)),
        ]);
      }
    }

    double totalFor(List<PurchaseItem> list) =>
        list.fold(0, (total, item) => total + item.amount);

    double deductibleFor(List<PurchaseItem> list) => list
        .where((item) => item.isDeductible)
        .fold(0, (total, item) => total + item.amount);

    summarySheet.appendRow([
      TextCellValue('Account'),
      TextCellValue('Entries'),
      TextCellValue('Total EUR'),
      TextCellValue('Deductible EUR'),
      TextCellValue('Non-deductible EUR'),
    ]);

    final total = totalFor(sorted);
    final deductible = deductibleFor(sorted);

    summarySheet.appendRow([
      TextCellValue(account.storageValue),
      TextCellValue(sorted.length.toString()),
      TextCellValue(total.toStringAsFixed(2)),
      TextCellValue(deductible.toStringAsFixed(2)),
      TextCellValue((total - deductible).toStringAsFixed(2)),
    ]);

    excel.delete('Sheet1');

    final bytes = excel.encode();
    if (bytes == null) {
      return;
    }

    final filename = 'expenses_tax_consultant_$timestamp.xlsx';
    await Share.shareXFiles(
      [
        XFile.fromData(
          Uint8List.fromList(bytes),
          mimeType:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          name: filename,
        ),
      ],
      subject: filename,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}

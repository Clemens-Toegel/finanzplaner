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
  }) async {
    if (items.isEmpty) {
      return;
    }

    final localeName = localizations.localeName;
    final dateFormat = DateFormat('yyyy-MM-dd', localeName);
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    final excel = Excel.createExcel();
    final expensesSheet = excel[localizations.excelSheetExpensesName];
    final summarySheet = excel[localizations.excelSheetSummaryName];

    expensesSheet.appendRow([
      TextCellValue(localizations.excelHeaderExpenseId),
      TextCellValue(localizations.excelHeaderDate),
      TextCellValue(localizations.excelHeaderCompanyRegisterNumber),
      TextCellValue(localizations.excelHeaderVendor),
      TextCellValue(localizations.excelHeaderDescription),
      TextCellValue(localizations.excelHeaderCategory),
      TextCellValue(localizations.excelHeaderAmountEur),
      TextCellValue(localizations.excelHeaderDeductible),
      TextCellValue(localizations.excelHeaderNotes),
      TextCellValue(localizations.excelHeaderSubItemDescription),
      TextCellValue(localizations.excelHeaderSubItemAmountEur),
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
          TextCellValue(
            item.isDeductible ? localizations.yesLabel : localizations.noLabel,
          ),
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
          TextCellValue(
            item.isDeductible ? localizations.yesLabel : localizations.noLabel,
          ),
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
      TextCellValue(localizations.excelSummaryHeaderEntries),
      TextCellValue(localizations.excelSummaryHeaderTotalEur),
      TextCellValue(localizations.excelSummaryHeaderDeductibleEur),
      TextCellValue(localizations.excelSummaryHeaderNonDeductibleEur),
    ]);

    final total = totalFor(sorted);
    final deductible = deductibleFor(sorted);

    summarySheet.appendRow([
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

    final filename = '${localizations.excelFileNamePrefix}_$timestamp.xlsx';
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
      sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
    );
  }
}

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';

class PdfExporter {
  Future<void> exportPurchases({
    required ExpenseAccountType account,
    required List<PurchaseItem> items,
    required AppLocalizations localizations,
  }) async {
    if (items.isEmpty) {
      return;
    }

    final localeName = localizations.localeName;
    final dateFormat = DateFormat('dd.MM.yyyy', localeName);
    final monthFormat = DateFormat('MMMM yyyy', localeName);
    final currencyFormat = NumberFormat.currency(
      locale: localeName,
      symbol: '€',
    );
    final sortedItems = List<PurchaseItem>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    final groupedItems = _groupItemsByMonth(sortedItems);
    final deductibleAmount = items
        .where((item) => item.isDeductible)
        .fold(0.0, (total, item) => total + item.amount);
    final totalAmount = items.fold(0.0, (total, item) => total + item.amount);
    final generatedAt = DateFormat('dd.MM.yyyy HH:mm', localeName)
        .format(DateTime.now());
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final theme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            localizations.pdfTitle(localizations.accountLabel(account)),
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(localizations.pdfGeneratedAt(generatedAt)),
          pw.SizedBox(height: 16),
          ..._buildMonthlySections(
            groupedItems: groupedItems,
            monthFormat: monthFormat,
            dateFormat: dateFormat,
            currencyFormat: currencyFormat,
            localizations: localizations,
          ),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  localizations.totalLabel(currencyFormat.format(totalAmount)),
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  localizations.deductibleTotalText(
                    currencyFormat.format(deductibleAmount),
                  ),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Map<DateTime, List<PurchaseItem>> _groupItemsByMonth(
    List<PurchaseItem> items,
  ) {
    final groupedItems = <DateTime, List<PurchaseItem>>{};
    for (final item in items) {
      final monthKey = DateTime(item.date.year, item.date.month);
      groupedItems.putIfAbsent(monthKey, () => []).add(item);
    }
    return groupedItems;
  }

  List<pw.Widget> _buildMonthlySections({
    required Map<DateTime, List<PurchaseItem>> groupedItems,
    required DateFormat monthFormat,
    required DateFormat dateFormat,
    required NumberFormat currencyFormat,
    required AppLocalizations localizations,
  }) {
    final widgets = <pw.Widget>[];

    for (final entry in groupedItems.entries) {
      final monthTotal = entry.value
          .fold(0.0, (total, item) => total + item.amount);
      widgets
        ..add(
          pw.Text(
            monthFormat.format(entry.key),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        )
        ..add(pw.SizedBox(height: 6))
        ..add(
          pw.Table.fromTextArray(
            headers: [
              localizations.pdfHeaderDate,
              localizations.pdfHeaderDescription,
              localizations.pdfHeaderVendor,
              localizations.pdfHeaderCategory,
              localizations.pdfHeaderAmount,
              localizations.pdfHeaderDeductible,
              localizations.pdfHeaderNotes,
            ],
            data: entry.value
                .map(
                  (item) => [
                    dateFormat.format(item.date),
                    item.description,
                    item.vendor,
                    item.category,
                    currencyFormat.format(item.amount),
                    item.isDeductible
                        ? localizations.yesLabel
                        : localizations.noLabel,
                    item.notes,
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FixedColumnWidth(70),
              4: const pw.FixedColumnWidth(60),
              5: const pw.FixedColumnWidth(55),
            },
          ),
        )
        ..add(pw.SizedBox(height: 6))
        ..add(
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              localizations.totalLabel(currencyFormat.format(monthTotal)),
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        )
        ..add(pw.SizedBox(height: 14));
    }

    return widgets;
  }
}

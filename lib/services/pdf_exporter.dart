import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';

class PdfExporter {
  Future<void> exportPurchases({
    required ExpenseAccountType account,
    required List<PurchaseItem> items,
    required AppLocalizations localizations,
    AccountSettings? accountSettings,
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

    // Chronological order is easier for tax review.
    final sortedItems = List<PurchaseItem>.from(items)
      ..sort((a, b) => a.date.compareTo(b.date));
    final groupedItems = _groupItemsByMonth(sortedItems);

    final deductibleAmount = sortedItems
        .where((item) => item.isDeductible)
        .fold(0.0, (total, item) => total + item.amount);
    final totalAmount = sortedItems.fold(
      0.0,
      (total, item) => total + item.amount,
    );

    final periodStart = sortedItems.first.date;
    final periodEnd = sortedItems.last.date;
    final generatedAt = DateFormat(
      'dd.MM.yyyy HH:mm',
      localeName,
    ).format(DateTime.now());
    final generatedAtIsoUtc = DateTime.now().toUtc().toIso8601String();
    final reportId =
        'EXP-${account.storageValue.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}';

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
          pw.SizedBox(height: 10),
          _buildReportMeta(
            reportId: reportId,
            account: account,
            accountSettings: accountSettings,
            periodStart: periodStart,
            periodEnd: periodEnd,
            dateFormat: dateFormat,
            generatedAtIsoUtc: generatedAtIsoUtc,
            localizations: localizations,
          ),
          pw.SizedBox(height: 12),
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

  pw.Widget _buildReportMeta({
    required String reportId,
    required ExpenseAccountType account,
    required AccountSettings? accountSettings,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateFormat dateFormat,
    required String generatedAtIsoUtc,
    required AppLocalizations localizations,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Report-ID: $reportId'),
          pw.Text('Konto/Account: ${localizations.accountLabel(account)}'),
          if (accountSettings != null && accountSettings.displayName.isNotEmpty)
            pw.Text(
              'Kontobezeichnung/Account name: ${accountSettings.displayName}',
            ),
          if (account == ExpenseAccountType.business &&
              accountSettings != null &&
              accountSettings.companyRegisterNumber.isNotEmpty)
            pw.Text(
              'Firmenbuchnummer: ${accountSettings.companyRegisterNumber}',
            ),
          pw.Text(
            'Zeitraum/Period: ${dateFormat.format(periodStart)} - ${dateFormat.format(periodEnd)}',
          ),
          pw.Text('Währung/Currency: EUR'),
          pw.Text('Generated-At-UTC (ISO-8601): $generatedAtIsoUtc'),
          pw.Text('Schema: expense_report_v1'),
        ],
      ),
    );
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

  List<List<String>> _rowsForItem(
    PurchaseItem item,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
    AppLocalizations localizations,
  ) {
    final expenseId = item.id?.toString() ?? 'N/A';
    final rows = <List<String>>[
      [
        expenseId,
        dateFormat.format(item.date),
        item.description,
        item.vendor,
        item.category,
        currencyFormat.format(item.amount),
        item.isDeductible ? localizations.yesLabel : localizations.noLabel,
        item.notes,
      ],
    ];

    for (var i = 0; i < item.subItems.length; i++) {
      final subItem = item.subItems[i];
      rows.add([
        '$expenseId.${i + 1}',
        '',
        '• ${subItem.description}',
        '',
        'Sub-item',
        currencyFormat.format(subItem.amount),
        '',
        '',
      ]);
    }

    return rows;
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
      final monthTotal = entry.value.fold(
        0.0,
        (total, item) => total + item.amount,
      );
      widgets
        ..add(
          pw.Text(
            monthFormat.format(entry.key),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        )
        ..add(pw.SizedBox(height: 6))
        ..add(
          pw.TableHelper.fromTextArray(
            headers: [
              'ID',
              localizations.pdfHeaderDate,
              localizations.pdfHeaderDescription,
              localizations.pdfHeaderVendor,
              localizations.pdfHeaderCategory,
              localizations.pdfHeaderAmount,
              localizations.pdfHeaderDeductible,
              localizations.pdfHeaderNotes,
            ],
            data: entry.value
                .expand(
                  (item) => _rowsForItem(
                    item,
                    dateFormat,
                    currencyFormat,
                    localizations,
                  ),
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FixedColumnWidth(38),
              1: const pw.FixedColumnWidth(52),
              5: const pw.FixedColumnWidth(54),
              6: const pw.FixedColumnWidth(44),
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

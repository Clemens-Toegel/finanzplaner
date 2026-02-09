import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../gen/app_localizations.dart';
import '../models/expense_item.dart';
import '../services/pdf_exporter.dart';
import '../widgets/info_chip.dart';

enum ExpenseDetailAction { edit, delete }

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({super.key, required this.item});

  final ExpenseItem item;

  Future<void> _downloadAttachment(
    BuildContext context,
    String filePath,
  ) async {
    final file = File(filePath);
    if (!await file.exists()) {
      if (!context.mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.receiptFileNotFoundMessage)));
      return;
    }

    await Share.shareXFiles([
      XFile(file.path, name: p.basename(file.path)),
    ], sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1));
  }

  Future<void> _exportExpensePdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await PdfExporter().exportExpenses(
        account: item.accountType,
        items: [item],
        localizations: l10n,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportSingleExpensePdfErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd.MM.yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'de_AT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenseDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.editExpenseAction,
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context, ExpenseDetailAction.edit);
            },
          ),
          IconButton(
            tooltip: l10n.exportSingleExpensePdfTooltip,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _exportExpensePdf(context),
          ),
          IconButton(
            tooltip: l10n.deleteExpenseAction,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteExpenseTitle),
                  content: Text(l10n.deleteExpenseMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancelAction),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.confirmDeleteAction),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true) {
                if (!context.mounted) {
                  return;
                }
                Navigator.pop(context, ExpenseDetailAction.delete);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            Text(
              item.description,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  InfoChip(
                    icon: Icons.calendar_today,
                    label: dateFormat.format(item.date),
                  ),
                  InfoChip(
                    icon: Icons.euro,
                    label: currencyFormat.format(item.amount),
                  ),
                  InfoChip(
                    icon: item.isDeductible
                        ? Icons.check_circle
                        : Icons.info_outline,
                    label: item.isDeductible
                        ? l10n.deductibleLabel
                        : l10n.notDeductibleLabel,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _DetailTile(
                label: l10n.vendorLabel,
                value: item.vendor.isEmpty ? l10n.unknownVendor : item.vendor,
              ),
            ),
            _DetailTile(label: l10n.categoryLabel, value: item.category),
            _DetailTile(
              label: l10n.dateOfExpenseLabel,
              value: dateFormat.format(item.date),
            ),
            _DetailTile(
              label: l10n.vatDeductibleLabel,
              value: item.isDeductible ? l10n.yesLabel : l10n.noLabel,
            ),
            if (item.subItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.stepSubItemsTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ...item.subItems.map(
                (subItem) => Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(subItem.description)),
                      Text(currencyFormat.format(subItem.amount)),
                    ],
                  ),
                ),
              ),
            ],
            if ((item.attachmentPath ?? '').trim().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.receiptSectionTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  onPressed: () =>
                      _downloadAttachment(context, item.attachmentPath!.trim()),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.downloadReceiptAction),
                ),
              ),
            ],
            if (item.secondaryAttachmentPaths.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.additionalImagesSectionTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ...item.secondaryAttachmentPaths.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadAttachment(context, entry.value),
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      l10n.downloadNamedImageAction(
                        entry.key < item.secondaryAttachmentNames.length
                            ? item.secondaryAttachmentNames[entry.key]
                            : l10n.imageNumberLabel(entry.key + 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (item.notes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.notesLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(item.notes),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../gen/app_localizations.dart';
import '../models/purchase_item.dart';
import '../widgets/info_chip.dart';

enum PurchaseDetailAction { edit, delete }

class PurchaseDetailPage extends StatelessWidget {
  const PurchaseDetailPage({super.key, required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd.MM.yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'de_AT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.purchaseDetailsTitle),
        actions: [
          IconButton(
            tooltip: l10n.editPurchaseAction,
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context, PurchaseDetailAction.edit);
            },
          ),
          IconButton(
            tooltip: l10n.deletePurchaseAction,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deletePurchaseTitle),
                  content: Text(l10n.deletePurchaseMessage),
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
                Navigator.pop(context, PurchaseDetailAction.delete);
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
            const SizedBox(height: 12),
            Wrap(
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
            const SizedBox(height: 20),
            _DetailTile(
              label: l10n.vendorLabel,
              value: item.vendor.isEmpty ? l10n.unknownVendor : item.vendor,
            ),
            _DetailTile(label: l10n.categoryLabel, value: item.category),
            _DetailTile(
              label: l10n.dateOfPurchaseLabel,
              value: dateFormat.format(item.date),
            ),
            _DetailTile(
              label: l10n.vatDeductibleLabel,
              value: item.isDeductible ? l10n.yesLabel : l10n.noLabel,
            ),
            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.notesLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(item.notes),
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

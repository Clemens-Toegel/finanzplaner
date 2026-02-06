import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../state/add_edit_purchase_controller.dart';

class AddEditPurchaseDetailsStep extends StatelessWidget {
  const AddEditPurchaseDetailsStep({
    super.key,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onScanReceipt,
    required this.onScanDocument,
  });

  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onScanReceipt;
  final VoidCallback onScanDocument;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AddEditPurchaseController>();
    final vm = context
        .select<
          AddEditPurchaseController,
          ({
            bool isScanning,
            String selectedCategory,
            DateTime selectedDate,
            bool isDeductible,
            double subItemsTotal,
            bool hasSubItems,
          })
        >(
          (c) => (
            isScanning: c.isScanning,
            selectedCategory: c.selectedCategory,
            selectedDate: c.selectedDate,
            isDeductible: c.isDeductible,
            subItemsTotal: c.subItemsTotal,
            hasSubItems: c.subItems.isNotEmpty,
          ),
        );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          l10n.offlineOcrPrivacyNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vm.isScanning ? null : onScanReceipt,
                icon: const Icon(Icons.receipt_long),
                label: Text(l10n.scanReceiptAction),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: vm.isScanning ? null : onScanDocument,
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(l10n.scanDocumentAction),
              ),
            ),
          ],
        ),
        if (vm.isScanning) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.descriptionController,
          decoration: InputDecoration(labelText: l10n.descriptionLabel),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.descriptionValidation;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.vendorController,
          decoration: InputDecoration(labelText: l10n.vendorLabel),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.amountController,
          decoration: InputDecoration(
            labelText: l10n.amountLabel,
            helperText: vm.hasSubItems
                ? l10n.subItemsSumHint(currencyFormat.format(vm.subItemsTotal))
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.amountValidation;
            }
            final parsed = double.tryParse(value.replaceAll(',', '.'));
            if (parsed == null || parsed <= 0) {
              return l10n.amountInvalidValidation;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(vm.selectedCategory),
          initialValue: vm.selectedCategory,
          decoration: InputDecoration(labelText: l10n.categoryLabel),
          items: controller.categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.setSelectedCategory(value);
            }
          },
        ),
        const SizedBox(height: 4),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.dateOfPurchaseLabel),
          subtitle: Text(dateFormat.format(vm.selectedDate)),
          trailing: TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: vm.selectedDate,
                firstDate: DateTime(2015),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.setSelectedDate(picked);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(l10n.pickDate),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.vatDeductibleLabel),
          value: vm.isDeductible,
          onChanged: controller.setIsDeductible,
        ),
      ],
    );
  }
}

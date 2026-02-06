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
            bool hasAttachment,
          })
        >(
          (c) => (
            isScanning: c.isScanning,
            selectedCategory: c.selectedCategory,
            selectedDate: c.selectedDate,
            isDeductible: c.isDeductible,
            subItemsTotal: c.subItemsTotal,
            hasSubItems: c.subItems.isNotEmpty,
            hasAttachment: c.hasAttachment,
          ),
        );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          l10n.offlineOcrPrivacyNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: vm.isScanning ? null : onScanReceipt,
                  icon: const Icon(Icons.receipt_long),
                  label: Text(l10n.scanReceiptAction),
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: vm.isScanning ? null : onScanDocument,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: Text(l10n.scanDocumentAction),
                ),
              ),
            ],
          ),
        ),
        if (vm.isScanning)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: LinearProgressIndicator(),
          ),
        if (vm.hasAttachment)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    'Beleg angehängt',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextFormField(
            controller: controller.descriptionController,
            decoration: InputDecoration(labelText: l10n.descriptionLabel),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.descriptionValidation;
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextFormField(
            controller: controller.vendorController,
            decoration: InputDecoration(labelText: l10n.vendorLabel),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: TextFormField(
            controller: controller.amountController,
            decoration: InputDecoration(
              labelText: l10n.amountLabel,
              helperText: vm.hasSubItems
                  ? l10n.subItemsSumHint(
                      currencyFormat.format(vm.subItemsTotal),
                    )
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
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: DropdownButtonFormField<String>(
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
        ),
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

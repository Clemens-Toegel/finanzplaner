import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../models/expense_sub_item.dart';
import '../../state/add_edit_purchase_controller.dart';

class AddEditPurchaseSubItemsStep extends StatelessWidget {
  const AddEditPurchaseSubItemsStep({
    super.key,
    required this.currencyFormat,
    required this.onAddOrEditSubItem,
  });

  final NumberFormat currencyFormat;
  final Future<void> Function({int? index}) onAddOrEditSubItem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AddEditPurchaseController>();
    final vm = context
        .select<
          AddEditPurchaseController,
          ({
            double subItemsTotal,
            double? remainingForSubItems,
            bool canAddSubItem,
            bool subItemsOverAllocated,
            List<ExpenseSubItem> subItems,
          })
        >(
          (c) => (
            subItemsTotal: c.subItemsTotal,
            remainingForSubItems: c.remainingForSubItems,
            canAddSubItem: c.canAddSubItem,
            subItemsOverAllocated: c.subItemsOverAllocated,
            subItems: c.subItems,
          ),
        );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text(
          l10n.subItemsHelpText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.subItemsTotalLabel),
                      Text(
                        currencyFormat.format(vm.subItemsTotal),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.remainingForSubItemsLabel),
                      Text(
                        vm.remainingForSubItems == null
                            ? '—'
                            : currencyFormat.format(vm.remainingForSubItems),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: OutlinedButton.icon(
            onPressed: vm.canAddSubItem ? () => onAddOrEditSubItem() : null,
            icon: const Icon(Icons.add),
            label: Text(l10n.addSubItemAction),
          ),
        ),
        if (vm.subItemsOverAllocated)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              l10n.subItemsExceedTotalValidation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (vm.subItems.isEmpty)
          Text(
            l10n.noSubItemsYet,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ...vm.subItems.asMap().entries.map((entry) {
          final index = entry.key;
          final subItem = entry.value;
          return Card(
            child: ListTile(
              title: Text(subItem.description),
              subtitle: Text(currencyFormat.format(subItem.amount)),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: l10n.editSubItemAction,
                    onPressed: () => onAddOrEditSubItem(index: index),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.deletePurchaseAction,
                    onPressed: () => controller.removeSubItemAt(index),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          );
        }),
        if (vm.subItems.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.applySubItemsTotalToAmount,
              child: Text(l10n.applySubItemsTotalAction),
            ),
          ),
      ],
    );
  }
}

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
    required this.onAddSecondaryImage,
    required this.onRemoveSecondaryImage,
    required this.onMoveSecondaryImage,
    required this.onRenameSecondaryImage,
  });

  final NumberFormat currencyFormat;
  final Future<void> Function({int? index}) onAddOrEditSubItem;
  final Future<void> Function() onAddSecondaryImage;
  final Future<void> Function(int index) onRemoveSecondaryImage;
  final void Function(int oldIndex, int newIndex) onMoveSecondaryImage;
  final Future<void> Function(int index) onRenameSecondaryImage;

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
            List<String> secondaryAttachmentPaths,
            List<String> secondaryAttachmentNames,
          })
        >(
          (c) => (
            subItemsTotal: c.subItemsTotal,
            remainingForSubItems: c.remainingForSubItems,
            canAddSubItem: c.canAddSubItem,
            subItemsOverAllocated: c.subItemsOverAllocated,
            subItems: c.subItems,
            secondaryAttachmentPaths: c.secondaryAttachmentPaths,
            secondaryAttachmentNames: c.secondaryAttachmentNames,
          ),
        );

    return ListView(
      padding: const EdgeInsets.only(top: 4),
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
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: OutlinedButton.icon(
            onPressed: onAddSecondaryImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              vm.secondaryAttachmentPaths.isEmpty
                  ? l10n.additionalImagesAddAction
                  : l10n.additionalImagesCountAction(
                      vm.secondaryAttachmentPaths.length,
                    ),
            ),
          ),
        ),
        if (vm.secondaryAttachmentPaths.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              spacing: 8,
              children: vm.secondaryAttachmentPaths.asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: Text(vm.secondaryAttachmentNames[index]),
                    subtitle: Text(
                      entry.value.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          tooltip: l10n.renameImageTooltip,
                          onPressed: () => onRenameSecondaryImage(index),
                          icon: const Icon(Icons.drive_file_rename_outline),
                        ),
                        IconButton(
                          tooltip: l10n.moveUpTooltip,
                          onPressed: index == 0
                              ? null
                              : () => onMoveSecondaryImage(index, index - 1),
                          icon: const Icon(Icons.keyboard_arrow_up),
                        ),
                        IconButton(
                          tooltip: l10n.moveDownTooltip,
                          onPressed:
                              index == vm.secondaryAttachmentPaths.length - 1
                              ? null
                              : () => onMoveSecondaryImage(index, index + 1),
                          icon: const Icon(Icons.keyboard_arrow_down),
                        ),
                        IconButton(
                          tooltip: l10n.deletePurchaseAction,
                          onPressed: () => onRemoveSecondaryImage(index),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              l10n.noSubItemsYet,
              style: Theme.of(context).textTheme.bodySmall,
            ),
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

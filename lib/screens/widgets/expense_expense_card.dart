import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gen/app_localizations.dart';
import '../../models/expense_item.dart';
import '../../widgets/info_chip.dart';

class ExpenseExpenseCard extends StatelessWidget {
  const ExpenseExpenseCard({
    super.key,
    required this.item,
    required this.localizations,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  final ExpenseItem item;
  final AppLocalizations localizations;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: selectedColor, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.description,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isSelectionMode)
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? selectedColor
                          : Theme.of(context).colorScheme.outline,
                    ),
                ],
              ),
              Text(
                '${item.vendor.isEmpty ? localizations.unknownVendor : item.vendor} • ${item.category}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
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
                          ? localizations.deductibleLabel
                          : localizations.notDeductibleLabel,
                    ),
                    if (item.subItems.isNotEmpty)
                      InfoChip(
                        icon: Icons.format_list_bulleted,
                        label: localizations.subItemsCountLabel(
                          item.subItems.length,
                        ),
                      ),
                    if (item.secondaryAttachmentPaths.isNotEmpty)
                      InfoChip(
                        icon: Icons.photo_library_outlined,
                        label: localizations.secondaryAttachmentsCountLabel(
                          item.secondaryAttachmentPaths.length,
                        ),
                      ),
                  ],
                ),
              ),
              if (item.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item.notes,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

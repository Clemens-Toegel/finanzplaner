import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gen/app_localizations.dart';
import '../../models/purchase_item.dart';
import '../../widgets/info_chip.dart';

class PurchaseExpenseCard extends StatelessWidget {
  const PurchaseExpenseCard({
    super.key,
    required this.item,
    required this.localizations,
    required this.dateFormat,
    required this.currencyFormat,
    required this.onTap,
  });

  final PurchaseItem item;
  final AppLocalizations localizations;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                item.description,
                style: Theme.of(context).textTheme.titleMedium,
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

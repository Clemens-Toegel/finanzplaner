import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../state/add_edit_purchase_controller.dart';

class AddEditPurchaseFooter extends StatelessWidget {
  const AddEditPurchaseFooter({
    super.key,
    required this.isEdit,
    required this.onCancel,
    required this.onSubmit,
    required this.onOpenExtraDetails,
  });

  final bool isEdit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final VoidCallback onOpenExtraDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AddEditPurchaseController>();

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        spacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: onOpenExtraDetails,
            icon: const Icon(Icons.playlist_add_outlined),
            label: Text('${l10n.stepSubItemsTitle} / ${l10n.notesLabel}'),
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  child: Text(l10n.cancelAction),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.descriptionController,
                  builder: (context, value, child) {
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.amountController,
                      builder: (context, amountValue, child) {
                        return FilledButton.icon(
                          onPressed: controller.hasMinimumDetails
                              ? onSubmit
                              : null,
                          icon: Icon(isEdit ? Icons.save : Icons.add),
                          label: Text(
                            isEdit ? l10n.savePurchaseAction : l10n.addPurchase,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

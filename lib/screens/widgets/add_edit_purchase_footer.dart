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
  });

  final bool isEdit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<AddEditPurchaseController>();
    final currentStep = context.select<AddEditPurchaseController, int>(
      (c) => c.currentStep,
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(top: 10, bottom: 4),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currentStep == 0
                      ? null
                      : () {
                          controller.pageController.previousPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          );
                        },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(l10n.stepBackAction),
                ),
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: currentStep == 2
                      ? null
                      : () {
                          controller.pageController.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          );
                        },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(l10n.stepNextAction),
                ),
              ),
            ],
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: OutlinedButton(
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/expense_account_type.dart';
import '../../state/add_edit_purchase_controller.dart';

class AddEditPurchaseHeader extends StatelessWidget {
  const AddEditPurchaseHeader({
    super.key,
    required this.selectedAccount,
    required this.isEdit,
    required this.accountColor,
  });

  final ExpenseAccountType selectedAccount;
  final bool isEdit;
  final Color accountColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentStep = context.select<AddEditPurchaseController, int>(
      (c) => c.currentStep,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: accountColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accountColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Icon(
                selectedAccount == ExpenseAccountType.business
                    ? Icons.business
                    : Icons.person,
                color: accountColor,
              ),
              Text(
                l10n.accountLabel(selectedAccount),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: accountColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            isEdit ? l10n.editPurchaseTitle : l10n.addPurchaseTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Text(
          currentStep == 0
              ? l10n.stepExpenseDetailsTitle
              : currentStep == 1
              ? l10n.stepSubItemsTitle
              : l10n.notesLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = index == currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: isActive ? 22 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? accountColor
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

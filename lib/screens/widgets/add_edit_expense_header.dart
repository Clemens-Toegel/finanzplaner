import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/expense_account_type.dart';

class AddEditExpenseHeader extends StatelessWidget {
  const AddEditExpenseHeader({
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

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              isEdit ? l10n.editExpenseTitle : l10n.addExpenseTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Text(
            l10n.stepExpenseDetailsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

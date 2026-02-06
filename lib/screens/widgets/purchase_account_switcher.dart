import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/expense_account_type.dart';

class PurchaseAccountSwitcher extends StatelessWidget {
  const PurchaseAccountSwitcher({
    super.key,
    required this.localizations,
    required this.selectedAccount,
    required this.onChanged,
    required this.accountColor,
  });

  final AppLocalizations localizations;
  final ExpenseAccountType selectedAccount;
  final ValueChanged<ExpenseAccountType> onChanged;
  final Color accountColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accountColor.withValues(alpha: 0.18),
              accountColor.withValues(alpha: 0.06),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accountColor.withValues(alpha: 0.35)),
        ),
        child: DropdownButtonFormField<ExpenseAccountType>(
          key: ValueKey(selectedAccount),
          initialValue: selectedAccount,
          decoration: InputDecoration(
            labelText: localizations.expenseAccountLabel,
            prefixIcon: Icon(
              selectedAccount == ExpenseAccountType.business
                  ? Icons.business
                  : Icons.person,
              color: accountColor,
            ),
          ),
          items: ExpenseAccountType.values
              .map(
                (account) => DropdownMenuItem(
                  value: account,
                  child: Text(localizations.accountLabel(account)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

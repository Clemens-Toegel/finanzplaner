import 'package:flutter/material.dart';

import '../models/account_settings.dart';
import '../models/expense_account_type.dart';

class AccountSettingsSheetController extends ChangeNotifier {
  AccountSettingsSheetController({
    required Map<ExpenseAccountType, AccountSettings> initialSettings,
    required ExpenseAccountType selectedAccount,
  }) : editingAccount = selectedAccount,
       personalNameController = TextEditingController(
         text: initialSettings[ExpenseAccountType.personal]?.displayName ?? '',
       ),
       businessNameController = TextEditingController(
         text: initialSettings[ExpenseAccountType.business]?.displayName ?? '',
       ),
       registerNumberController = TextEditingController(
         text:
             initialSettings[ExpenseAccountType.business]
                 ?.companyRegisterNumber ??
             '',
       );

  ExpenseAccountType editingAccount;
  final TextEditingController personalNameController;
  final TextEditingController businessNameController;
  final TextEditingController registerNumberController;

  bool get isBusiness => editingAccount == ExpenseAccountType.business;

  TextEditingController get currentNameController =>
      isBusiness ? businessNameController : personalNameController;

  void setEditingAccount(ExpenseAccountType account) {
    if (editingAccount == account) {
      return;
    }
    editingAccount = account;
    notifyListeners();
  }

  Map<ExpenseAccountType, AccountSettings> buildSettings() {
    return {
      ExpenseAccountType.personal: AccountSettings(
        accountType: ExpenseAccountType.personal,
        displayName: personalNameController.text.trim(),
      ),
      ExpenseAccountType.business: AccountSettings(
        accountType: ExpenseAccountType.business,
        displayName: businessNameController.text.trim(),
        companyRegisterNumber: registerNumberController.text.trim(),
      ),
    };
  }

  @override
  void dispose() {
    personalNameController.dispose();
    businessNameController.dispose();
    registerNumberController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/account_settings.dart';
import '../../models/expense_account_type.dart';

class AccountSettingsSheet extends StatefulWidget {
  const AccountSettingsSheet({
    super.key,
    required this.initialSettings,
    required this.selectedAccount,
    required this.onSave,
  });

  final Map<ExpenseAccountType, AccountSettings> initialSettings;
  final ExpenseAccountType selectedAccount;
  final Future<void> Function(Map<ExpenseAccountType, AccountSettings> settings)
  onSave;

  @override
  State<AccountSettingsSheet> createState() => _AccountSettingsSheetState();
}

class _AccountSettingsSheetState extends State<AccountSettingsSheet> {
  final _formKey = GlobalKey<FormState>();

  late ExpenseAccountType _editingAccount;
  late final TextEditingController _personalNameController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _registerNumberController;

  @override
  void initState() {
    super.initState();
    _editingAccount = widget.selectedAccount;
    _personalNameController = TextEditingController(
      text:
          widget.initialSettings[ExpenseAccountType.personal]?.displayName ??
          '',
    );
    _businessNameController = TextEditingController(
      text:
          widget.initialSettings[ExpenseAccountType.business]?.displayName ??
          '',
    );
    _registerNumberController = TextEditingController(
      text:
          widget
              .initialSettings[ExpenseAccountType.business]
              ?.companyRegisterNumber ??
          '',
    );
  }

  @override
  void dispose() {
    _personalNameController.dispose();
    _businessNameController.dispose();
    _registerNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBusiness = _editingAccount == ExpenseAccountType.business;
    final currentNameController = isBusiness
        ? _businessNameController
        : _personalNameController;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.accountSettingsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              DropdownButtonFormField<ExpenseAccountType>(
                initialValue: _editingAccount,
                decoration: InputDecoration(
                  labelText: l10n.expenseAccountLabel,
                ),
                items: ExpenseAccountType.values
                    .map(
                      (account) => DropdownMenuItem(
                        value: account,
                        child: Text(l10n.accountLabel(account)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _editingAccount = value;
                  });
                },
              ),
              TextFormField(
                controller: currentNameController,
                decoration: InputDecoration(
                  labelText: l10n.accountDisplayNameLabel,
                ),
              ),
              if (isBusiness)
                TextFormField(
                  controller: _registerNumberController,
                  decoration: InputDecoration(
                    labelText: l10n.firmenbuchnummerLabel,
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return null;
                    }
                    if (!RegExp(r'^[A-Za-z0-9\-\s/]+$').hasMatch(text)) {
                      return l10n.firmenbuchnummerValidation;
                    }
                    return null;
                  },
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancelAction),
                  ),
                  FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      final settings = <ExpenseAccountType, AccountSettings>{
                        ExpenseAccountType.personal: AccountSettings(
                          accountType: ExpenseAccountType.personal,
                          displayName: _personalNameController.text.trim(),
                        ),
                        ExpenseAccountType.business: AccountSettings(
                          accountType: ExpenseAccountType.business,
                          displayName: _businessNameController.text.trim(),
                          companyRegisterNumber: _registerNumberController.text
                              .trim(),
                        ),
                      };

                      await widget.onSave(settings);
                      if (!mounted) {
                        return;
                      }
                      Navigator.of(this.context).pop(true);
                    },
                    child: Text(l10n.saveSettingsAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

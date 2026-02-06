import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/account_settings.dart';
import '../../models/expense_account_type.dart';
import '../../state/account_settings_sheet_controller.dart';

class AccountSettingsSheet extends StatelessWidget {
  const AccountSettingsSheet({
    super.key,
    required this.initialSettings,
    required this.selectedAccount,
    required this.onSave,
    required this.onExportExcel,
  });

  final Map<ExpenseAccountType, AccountSettings> initialSettings;
  final ExpenseAccountType selectedAccount;
  final Future<void> Function(Map<ExpenseAccountType, AccountSettings> settings)
  onSave;
  final Future<void> Function(Rect sharePositionOrigin) onExportExcel;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountSettingsSheetController(
        initialSettings: initialSettings,
        selectedAccount: selectedAccount,
      ),
      child: _AccountSettingsSheetContent(
        onSave: onSave,
        onExportExcel: onExportExcel,
      ),
    );
  }
}

class _AccountSettingsSheetContent extends StatelessWidget {
  _AccountSettingsSheetContent({
    required this.onSave,
    required this.onExportExcel,
  });

  final _formKey = GlobalKey<FormState>();
  final Future<void> Function(Map<ExpenseAccountType, AccountSettings> settings)
  onSave;
  final Future<void> Function(Rect sharePositionOrigin) onExportExcel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AccountSettingsSheetController>(
      builder: (context, controller, child) {
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
                    initialValue: controller.editingAccount,
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
                      controller.setEditingAccount(value);
                    },
                  ),
                  TextFormField(
                    key: ValueKey(controller.editingAccount),
                    controller: controller.currentNameController,
                    decoration: InputDecoration(
                      labelText: l10n.accountDisplayNameLabel,
                    ),
                  ),
                  if (controller.isBusiness)
                    TextFormField(
                      controller: controller.registerNumberController,
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
                  const Divider(height: 24),
                  Text(
                    l10n.dataExportTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Builder(
                    builder: (buttonContext) {
                      return OutlinedButton.icon(
                        onPressed: controller.isExporting
                            ? null
                            : () async {
                                final box =
                                    buttonContext.findRenderObject()
                                        as RenderBox?;
                                final sharePositionOrigin =
                                    box == null || !box.hasSize
                                    ? const Rect.fromLTWH(1, 1, 1, 1)
                                    : box.localToGlobal(Offset.zero) & box.size;
                                controller.setExporting(true);
                                try {
                                  await onExportExcel(sharePositionOrigin);
                                } finally {
                                  if (buttonContext.mounted) {
                                    controller.setExporting(false);
                                  }
                                }
                              },
                        icon: controller.isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.table_view_outlined),
                        label: Text(l10n.exportExcelForTaxConsultantAction),
                      );
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

                          await onSave(controller.buildSettings());
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop(true);
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
      },
    );
  }
}

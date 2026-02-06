import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/expense_account_type.dart';
import '../../models/expense_sub_item.dart';
import '../../models/purchase_item.dart';
import '../../services/offline_bill_ocr_service.dart';
import '../../state/add_edit_purchase_controller.dart';
import 'add_edit_purchase_details_step.dart';
import 'add_edit_purchase_footer.dart';
import 'add_edit_purchase_header.dart';
import 'add_edit_purchase_notes_step.dart';
import 'add_edit_purchase_sub_items_step.dart';

class AddEditPurchaseSheet extends StatelessWidget {
  const AddEditPurchaseSheet({
    super.key,
    required this.selectedAccount,
    required this.ocrService,
    required this.dateFormat,
    required this.currencyFormat,
    this.item,
  });

  final ExpenseAccountType selectedAccount;
  final PurchaseItem? item;
  final OfflineBillOcrService ocrService;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    final categories = AppLocalizations.of(
      context,
    )!.categoriesForAccount(selectedAccount);

    return ChangeNotifierProvider(
      create: (_) => AddEditPurchaseController(
        selectedAccount: selectedAccount,
        categories: categories,
        item: item,
      ),
      child: _AddEditPurchaseSheetContent(
        selectedAccount: selectedAccount,
        item: item,
        ocrService: ocrService,
        dateFormat: dateFormat,
        currencyFormat: currencyFormat,
      ),
    );
  }
}

class _AddEditPurchaseSheetContent extends StatelessWidget {
  _AddEditPurchaseSheetContent({
    required this.selectedAccount,
    required this.item,
    required this.ocrService,
    required this.dateFormat,
    required this.currencyFormat,
  });

  final _formKey = GlobalKey<FormState>();
  final ExpenseAccountType selectedAccount;
  final PurchaseItem? item;
  final OfflineBillOcrService ocrService;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;

  Color _accountColor() {
    return selectedAccount == ExpenseAccountType.business
        ? Colors.blue
        : Colors.orange;
  }

  Future<void> _submitForm(
    BuildContext context,
    AddEditPurchaseController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    controller.ensureAmountFromSubItemsIfMissing();

    if (!controller.hasMinimumDetails) {
      _formKey.currentState!.validate();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parsedAmount = double.parse(
      controller.amountController.text.replaceAll(',', '.'),
    );
    final hasSubItemAboveTotal = controller.subItems.any(
      (subItem) => subItem.amount > parsedAmount,
    );

    if (hasSubItemAboveTotal || controller.subItemsTotal > parsedAmount) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subItemsExceedTotalValidation)),
      );
      await _openExtraDetailsSheet(context, controller);
      return;
    }

    final draft = controller.tryBuildDraft();
    if (draft == null || !context.mounted) {
      return;
    }

    Navigator.of(context).pop(draft);
  }

  Future<void> _scanBill(
    BuildContext context,
    AddEditPurchaseController controller,
    BillScanMode mode, {
    BillImageSource source = BillImageSource.camera,
  }) async {
    if (controller.isScanning) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    controller.setScanning(true);

    try {
      final data = await ocrService.scanBill(mode: mode, source: source);
      if (!context.mounted || data == null) {
        return;
      }

      if (data.rawText.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ocrNoTextFound)));
        return;
      }

      controller.applyOcrDataToForm(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ocrAppliedMessage)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ocrErrorMessage)));
    } finally {
      if (context.mounted) {
        controller.setScanning(false);
      }
    }
  }

  Future<void> _scanA4Bill(
    BuildContext context,
    AddEditPurchaseController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<BillImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.scanFromCameraAction),
                onTap: () => Navigator.pop(context, BillImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.scanFromGalleryAction),
                onTap: () => Navigator.pop(context, BillImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !context.mounted) {
      return;
    }

    await _scanBill(context, controller, BillScanMode.a4Bill, source: source);
  }

  Future<void> _addOrEditSubItem(
    BuildContext context,
    AddEditPurchaseController controller, {
    int? index,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = index != null ? controller.subItems[index] : null;
    final totalAmount = controller.totalAmountValue;
    final allocatedWithoutCurrent =
        controller.subItems.fold<double>(
          0,
          (total, subItem) => total + subItem.amount,
        ) -
        (existing?.amount ?? 0);

    if (index == null &&
        totalAmount != null &&
        allocatedWithoutCurrent >= totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subItemsExceedTotalValidation)),
      );
      return;
    }

    final subItemDescriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final subItemAmountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );

    final added = await showDialog<ExpenseSubItem>(
      context: context,
      builder: (context) {
        final dialogFormKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text(
            existing == null ? l10n.addSubItemAction : l10n.editSubItemAction,
          ),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                TextFormField(
                  controller: subItemDescriptionController,
                  decoration: InputDecoration(labelText: l10n.descriptionLabel),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.descriptionValidation;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: subItemAmountController,
                  decoration: InputDecoration(labelText: l10n.amountLabel),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.amountValidation;
                    }
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return l10n.amountInvalidValidation;
                    }

                    if (totalAmount != null) {
                      if (parsed > totalAmount) {
                        return l10n.subItemAmountExceedsTotalValidation;
                      }
                      if (allocatedWithoutCurrent + parsed > totalAmount) {
                        return l10n.subItemsExceedTotalValidation;
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () {
                if (!dialogFormKey.currentState!.validate()) {
                  return;
                }

                final amount = double.parse(
                  subItemAmountController.text.replaceAll(',', '.'),
                );

                Navigator.pop(
                  context,
                  ExpenseSubItem(
                    description: subItemDescriptionController.text.trim(),
                    amount: amount,
                  ),
                );
              },
              child: Text(l10n.savePurchaseAction),
            ),
          ],
        );
      },
    );

    if (added == null || !context.mounted) {
      return;
    }

    final candidateSubItems = List<ExpenseSubItem>.from(controller.subItems);
    if (index == null) {
      candidateSubItems.add(added);
    } else {
      candidateSubItems[index] = added;
    }

    if (totalAmount != null) {
      final subItemsSum = candidateSubItems.fold<double>(
        0,
        (total, subItem) => total + subItem.amount,
      );
      final hasItemAboveTotal = candidateSubItems.any(
        (subItem) => subItem.amount > totalAmount,
      );

      if (hasItemAboveTotal || subItemsSum > totalAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.subItemsExceedTotalValidation)),
        );
        return;
      }
    }

    controller.upsertSubItem(added, index: index);
  }

  Future<void> _openExtraDetailsSheet(
    BuildContext context,
    AddEditPurchaseController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: controller,
          child: DefaultTabController(
            length: 2,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: l10n.stepSubItemsTitle),
                        Tab(text: l10n.notesLabel),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TabBarView(
                        children: [
                          AddEditPurchaseSubItemsStep(
                            currencyFormat: currencyFormat,
                            onAddOrEditSubItem: ({index}) => _addOrEditSubItem(
                              sheetContext,
                              controller,
                              index: index,
                            ),
                          ),
                          const AddEditPurchaseNotesStep(),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(l10n.savePurchaseAction),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestClose(
    BuildContext context,
    AddEditPurchaseController controller,
  ) async {
    if (!controller.hasUnsavedChanges()) {
      Navigator.of(context).pop();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.discardChangesAction),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AddEditPurchaseController>();

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 8,
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _requestClose(context, controller);
          }
        },
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AddEditPurchaseHeader(
                selectedAccount: selectedAccount,
                isEdit: item != null,
                accountColor: _accountColor(),
              ),
              Expanded(
                child: AddEditPurchaseDetailsStep(
                  dateFormat: dateFormat,
                  currencyFormat: currencyFormat,
                  onScanReceipt: () =>
                      _scanBill(context, controller, BillScanMode.shopReceipt),
                  onScanDocument: () => _scanA4Bill(context, controller),
                ),
              ),
              AddEditPurchaseFooter(
                isEdit: item != null,
                onCancel: () => _requestClose(context, controller),
                onSubmit: () => _submitForm(context, controller),
                onOpenExtraDetails: () =>
                    _openExtraDetailsSheet(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

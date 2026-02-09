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
    this.initialScanMode,
    this.initialScanSource = BillImageSource.camera,
  });

  final ExpenseAccountType selectedAccount;
  final PurchaseItem? item;
  final OfflineBillOcrService ocrService;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final BillScanMode? initialScanMode;
  final BillImageSource initialScanSource;

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
        initialScanMode: initialScanMode,
        initialScanSource: initialScanSource,
      ),
    );
  }
}

class _AddEditPurchaseSheetContent extends StatefulWidget {
  const _AddEditPurchaseSheetContent({
    required this.selectedAccount,
    required this.item,
    required this.ocrService,
    required this.dateFormat,
    required this.currencyFormat,
    required this.initialScanMode,
    required this.initialScanSource,
  });

  final ExpenseAccountType selectedAccount;
  final PurchaseItem? item;
  final OfflineBillOcrService ocrService;
  final DateFormat dateFormat;
  final NumberFormat currencyFormat;
  final BillScanMode? initialScanMode;
  final BillImageSource initialScanSource;

  @override
  State<_AddEditPurchaseSheetContent> createState() =>
      _AddEditPurchaseSheetContentState();
}

class _AddEditPurchaseSheetContentState
    extends State<_AddEditPurchaseSheetContent> {
  final _formKey = GlobalKey<FormState>();
  bool _didRunInitialScan = false;

  ExpenseAccountType get selectedAccount => widget.selectedAccount;

  PurchaseItem? get item => widget.item;

  OfflineBillOcrService get ocrService => widget.ocrService;

  DateFormat get dateFormat => widget.dateFormat;

  NumberFormat get currencyFormat => widget.currencyFormat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRunInitialScan || widget.initialScanMode == null) {
      return;
    }

    _didRunInitialScan = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = context.read<AddEditPurchaseController>();
      _scanBill(
        context,
        controller,
        widget.initialScanMode!,
        source: widget.initialScanSource,
      );
    });
  }

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

    if ((controller.pendingAttachmentSourcePath ?? '').trim().isNotEmpty) {
      final storedAttachmentPath = await ocrService.persistAttachment(
        controller.pendingAttachmentSourcePath!,
      );
      if (storedAttachmentPath != null) {
        controller.setAttachmentPath(storedAttachmentPath);
      }
      controller.clearPendingAttachmentSourcePath();
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

      controller.applyOcrDataToForm(data);

      if (data.rawText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ocrNoTextFoundWithAttachment)),
        );
        return;
      }

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

  Future<BillImageSource?> _pickImageSource(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<BillImageSource>(
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
  }

  Future<void> _scanA4Bill(
    BuildContext context,
    AddEditPurchaseController controller,
  ) async {
    final source = await _pickImageSource(context);

    if (source == null || !context.mounted) {
      return;
    }

    await _scanBill(context, controller, BillScanMode.a4Bill, source: source);
  }

  Future<void> _addSecondaryImage(
    BuildContext context,
    AddEditPurchaseController controller,
  ) async {
    final source = await _pickImageSource(context);
    if (source == null || !context.mounted) {
      return;
    }

    final sourcePath = await ocrService.pickBillImage(source: source);
    if (sourcePath == null || !context.mounted) {
      return;
    }

    final storedPath = await ocrService.persistAttachment(sourcePath);
    if (!context.mounted) {
      return;
    }
    if (storedPath == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.imageSaveFailedMessage)));
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    controller.addSecondaryAttachmentPath(storedPath);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.secondaryImageAddedMessage)));
  }

  Future<void> _removeSecondaryImage(
    BuildContext context,
    AddEditPurchaseController controller,
    int index,
  ) async {
    if (index < 0 || index >= controller.secondaryAttachmentPaths.length) {
      return;
    }

    final path = controller.secondaryAttachmentPaths[index];
    final initialPaths = item?.secondaryAttachmentPaths ?? const <String>[];
    controller.removeSecondaryAttachmentAt(index);

    if (!initialPaths.contains(path)) {
      await ocrService.deleteStoredAttachment(path);
    }
  }

  ({String name, String extension}) _splitNameAndExtension(String filename) {
    final trimmed = filename.trim();
    if (trimmed.isEmpty) {
      return (name: '', extension: '');
    }

    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == trimmed.length - 1) {
      return (name: trimmed, extension: '');
    }

    return (
      name: trimmed.substring(0, dotIndex),
      extension: trimmed.substring(dotIndex),
    );
  }

  Future<void> _renameSecondaryImage(
    BuildContext context,
    AddEditPurchaseController controller,
    int index,
  ) async {
    if (index < 0 || index >= controller.secondaryAttachmentNames.length) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final currentName = controller.secondaryAttachmentNames[index];
    final splitName = _splitNameAndExtension(currentName);

    final nameController = TextEditingController(text: splitName.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameImageTitle),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.nameLabel,
            suffixText: splitName.extension.isEmpty
                ? null
                : splitName.extension,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () {
              final baseName = nameController.text.trim();
              if (baseName.isEmpty) {
                Navigator.pop(dialogContext, '');
                return;
              }
              Navigator.pop(dialogContext, '$baseName${splitName.extension}');
            },
            child: Text(l10n.savePurchaseAction),
          ),
        ],
      ),
    );

    if (newName == null) {
      return;
    }

    controller.renameSecondaryAttachment(index, newName);
  }

  void _moveSecondaryImage(
    AddEditPurchaseController controller,
    int oldIndex,
    int newIndex,
  ) {
    controller.moveSecondaryAttachment(oldIndex, newIndex);
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
        return SafeArea(
          top: false,
          child: ChangeNotifierProvider.value(
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
                              onAddOrEditSubItem: ({index}) =>
                                  _addOrEditSubItem(
                                    sheetContext,
                                    controller,
                                    index: index,
                                  ),
                              onAddSecondaryImage: () =>
                                  _addSecondaryImage(sheetContext, controller),
                              onRemoveSecondaryImage: (index) =>
                                  _removeSecondaryImage(
                                    sheetContext,
                                    controller,
                                    index,
                                  ),
                              onMoveSecondaryImage: (oldIndex, newIndex) =>
                                  _moveSecondaryImage(
                                    controller,
                                    oldIndex,
                                    newIndex,
                                  ),
                              onRenameSecondaryImage: (index) =>
                                  _renameSecondaryImage(
                                    sheetContext,
                                    controller,
                                    index,
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
      final initialAttachment = item?.attachmentPath?.trim() ?? '';
      final currentAttachment = controller.attachmentPath?.trim() ?? '';
      if (currentAttachment.isNotEmpty &&
          currentAttachment != initialAttachment) {
        await ocrService.deleteStoredAttachment(currentAttachment);
        if (!context.mounted) {
          return;
        }
      }

      final initialSecondary =
          item?.secondaryAttachmentPaths ?? const <String>[];
      final currentSecondary = controller.secondaryAttachmentPaths;
      final newlyAddedSecondary = currentSecondary
          .where((path) => !initialSecondary.contains(path))
          .toList();
      for (final path in newlyAddedSecondary) {
        await ocrService.deleteStoredAttachment(path);
      }
      if (!context.mounted) {
        return;
      }

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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../gen/app_localizations.dart';
import '../../localization/app_localizations_ext.dart';
import '../../models/expense_account_type.dart';
import '../../models/expense_sub_item.dart';
import '../../models/ocr_bill_data.dart';
import '../../models/purchase_item.dart';
import '../../services/offline_bill_ocr_service.dart';

class AddEditPurchaseSheet extends StatefulWidget {
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
  State<AddEditPurchaseSheet> createState() => _AddEditPurchaseSheetState();
}

class _AddEditPurchaseSheetState extends State<AddEditPurchaseSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _vendorController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final PageController _pageController;

  late DateTime _selectedDate;
  late String _selectedCategory;
  late bool _isDeductible;
  bool _isScanning = false;
  int _currentStep = 0;
  late List<ExpenseSubItem> _subItems;

  late final String _initialDescription;
  late final String _initialVendor;
  late final String _initialAmount;
  late final String _initialNotes;
  late final String _initialCategory;
  late final DateTime _initialDate;
  late final bool _initialIsDeductible;
  late final List<ExpenseSubItem> _initialSubItems;

  Color _accountColor() {
    return widget.selectedAccount == ExpenseAccountType.business
        ? Colors.blue
        : Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _vendorController = TextEditingController(text: item?.vendor ?? '');
    _amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: item?.notes ?? '');
    _pageController = PageController(initialPage: 0);
    _subItems = List<ExpenseSubItem>.from(item?.subItems ?? const []);

    _selectedDate = item?.date ?? DateTime.now();
    _selectedCategory = item?.category ?? '';
    _isDeductible = item?.isDeductible ?? true;

    _initialDescription = _descriptionController.text.trim();
    _initialVendor = _vendorController.text.trim();
    _initialAmount = _amountController.text.trim();
    _initialNotes = _notesController.text.trim();
    _initialCategory = _selectedCategory;
    _initialDate = _selectedDate;
    _initialIsDeductible = _isDeductible;
    _initialSubItems = List<ExpenseSubItem>.from(_subItems);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = AppLocalizations.of(
      context,
    )!.categoriesForAccount(widget.selectedAccount);
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _vendorController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_amountController.text.trim().isEmpty && _subItems.isNotEmpty) {
      final sum = _subItems.fold<double>(
        0,
        (total, subItem) => total + subItem.amount,
      );
      _amountController.text = sum.toStringAsFixed(2);
    }

    final hasMinimumDetails =
        _descriptionController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty;

    if (!hasMinimumDetails) {
      if (_currentStep != 0) {
        await _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
      _formKey.currentState!.validate();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      if (_currentStep != 0) {
        await _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    final parsedAmount = double.parse(
      _amountController.text.replaceAll(',', '.'),
    );
    final subItemsSum = _subItems.fold<double>(
      0,
      (total, subItem) => total + subItem.amount,
    );
    final hasSubItemAboveTotal = _subItems.any(
      (subItem) => subItem.amount > parsedAmount,
    );

    if (hasSubItemAboveTotal || subItemsSum > parsedAmount) {
      if (_currentStep != 1) {
        await _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
      if (!mounted) {
        return;
      }
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subItemsExceedTotalValidation)),
      );
      return;
    }

    final item = PurchaseItem(
      id: widget.item?.id,
      accountType: widget.selectedAccount,
      description: _descriptionController.text.trim(),
      vendor: _vendorController.text.trim(),
      category: _selectedCategory,
      amount: parsedAmount,
      date: _selectedDate,
      isDeductible: _isDeductible,
      notes: _notesController.text.trim(),
      subItems: _subItems,
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(item);
  }

  Future<void> _scanBill(
    BillScanMode mode, {
    BillImageSource source = BillImageSource.camera,
  }) async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final data = await widget.ocrService.scanBill(mode: mode, source: source);
      if (!mounted || data == null) {
        return;
      }

      if (data.rawText.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ocrNoTextFound)));
        return;
      }

      setState(() {
        _applyOcrDataToForm(data);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ocrAppliedMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.ocrErrorMessage)));
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _scanA4Bill() async {
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

    if (source == null) {
      return;
    }

    await _scanBill(BillScanMode.a4Bill, source: source);
  }

  Future<void> _addOrEditSubItem({int? index}) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = index != null ? _subItems[index] : null;
    final totalAmount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    final allocatedWithoutCurrent =
        _subItems.fold<double>(0, (total, subItem) => total + subItem.amount) -
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

    if (added == null || !mounted) {
      return;
    }

    final candidateSubItems = List<ExpenseSubItem>.from(_subItems);
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

    setState(() {
      if (index == null) {
        _subItems.add(added);
      } else {
        _subItems[index] = added;
      }
    });
  }

  bool _hasUnsavedChanges() {
    if (_descriptionController.text.trim() != _initialDescription) {
      return true;
    }
    if (_vendorController.text.trim() != _initialVendor) {
      return true;
    }
    if (_amountController.text.trim() != _initialAmount) {
      return true;
    }
    if (_notesController.text.trim() != _initialNotes) {
      return true;
    }
    if (_selectedCategory != _initialCategory) {
      return true;
    }
    if (_selectedDate != _initialDate) {
      return true;
    }
    if (_isDeductible != _initialIsDeductible) {
      return true;
    }
    if (_subItems.length != _initialSubItems.length) {
      return true;
    }
    for (var i = 0; i < _subItems.length; i++) {
      final current = _subItems[i];
      final initial = _initialSubItems[i];
      if (current.description != initial.description ||
          current.amount != initial.amount) {
        return true;
      }
    }
    return false;
  }

  Future<void> _requestClose() async {
    if (!_hasUnsavedChanges()) {
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

    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _applyOcrDataToForm(OcrBillData data) {
    if (data.description != null && data.description!.trim().isNotEmpty) {
      _descriptionController.text = data.description!.trim();
    }
    if (data.vendor != null && data.vendor!.trim().isNotEmpty) {
      _vendorController.text = data.vendor!.trim();
    }
    if (data.amount != null && data.amount! > 0) {
      _amountController.text = data.amount!.toStringAsFixed(2);
    }
    if (data.date != null) {
      _selectedDate = data.date!;
    }
    if (data.subItems.isNotEmpty) {
      _subItems = List<ExpenseSubItem>.from(data.subItems);
      if (data.amount == null || data.amount! <= 0) {
        final sum = data.subItems.fold<double>(
          0,
          (total, subItem) => total + subItem.amount,
        );
        if (sum > 0) {
          _amountController.text = sum.toStringAsFixed(2);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = l10n.categoriesForAccount(widget.selectedAccount);

    final subItemsTotal = _subItems.fold<double>(
      0,
      (total, entry) => total + entry.amount,
    );
    final totalAmountValue = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    final remainingForSubItems = totalAmountValue != null
        ? (totalAmountValue - subItemsTotal)
        : null;
    final canAddSubItem =
        remainingForSubItems == null || remainingForSubItems > 0;
    final subItemsOverAllocated =
        remainingForSubItems != null && remainingForSubItems < 0;

    return SafeArea(
      child: AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _requestClose();
            }
          },
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _accountColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _accountColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(
                          widget.selectedAccount == ExpenseAccountType.business
                              ? Icons.business
                              : Icons.person,
                          color: _accountColor(),
                        ),
                        Text(
                          l10n.accountLabel(widget.selectedAccount),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: _accountColor(),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      widget.item == null
                          ? l10n.addPurchaseTitle
                          : l10n.editPurchaseTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Text(
                    _currentStep == 0
                        ? l10n.stepExpenseDetailsTitle
                        : _currentStep == 1
                        ? l10n.stepSubItemsTitle
                        : l10n.notesLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index == _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 22 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _accountColor()
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      children: [
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              l10n.offlineOcrPrivacyNote,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isScanning
                                        ? null
                                        : () => _scanBill(
                                            BillScanMode.shopReceipt,
                                          ),
                                    icon: const Icon(Icons.receipt_long),
                                    label: Text(l10n.scanReceiptAction),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isScanning ? null : _scanA4Bill,
                                    icon: const Icon(
                                      Icons.document_scanner_outlined,
                                    ),
                                    label: Text(l10n.scanDocumentAction),
                                  ),
                                ),
                              ],
                            ),
                            if (_isScanning) ...[
                              const SizedBox(height: 12),
                              const LinearProgressIndicator(),
                            ],
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: l10n.descriptionLabel,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.descriptionValidation;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _vendorController,
                              decoration: InputDecoration(
                                labelText: l10n.vendorLabel,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: l10n.amountLabel,
                                helperText: _subItems.isNotEmpty
                                    ? l10n.subItemsSumHint(
                                        widget.currencyFormat.format(
                                          subItemsTotal,
                                        ),
                                      )
                                    : null,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.amountValidation;
                                }
                                final parsed = double.tryParse(
                                  value.replaceAll(',', '.'),
                                );
                                if (parsed == null || parsed <= 0) {
                                  return l10n.amountInvalidValidation;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: l10n.categoryLabel,
                              ),
                              items: categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                            const SizedBox(height: 4),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.dateOfPurchaseLabel),
                              subtitle: Text(
                                widget.dateFormat.format(_selectedDate),
                              ),
                              trailing: TextButton.icon(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2015),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDate = picked;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(l10n.pickDate),
                              ),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.vatDeductibleLabel),
                              value: _isDeductible,
                              onChanged: (value) {
                                setState(() {
                                  _isDeductible = value;
                                });
                              },
                            ),
                          ],
                        ),
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              l10n.subItemsHelpText,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            Card(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(l10n.subItemsTotalLabel),
                                        Text(
                                          widget.currencyFormat.format(
                                            subItemsTotal,
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(l10n.remainingForSubItemsLabel),
                                        Text(
                                          remainingForSubItems == null
                                              ? '—'
                                              : widget.currencyFormat.format(
                                                  remainingForSubItems,
                                                ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: canAddSubItem
                                  ? () => _addOrEditSubItem()
                                  : null,
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addSubItemAction),
                            ),
                            const SizedBox(height: 10),
                            if (subItemsOverAllocated)
                              Text(
                                l10n.subItemsExceedTotalValidation,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            if (_subItems.isEmpty)
                              Text(
                                l10n.noSubItemsYet,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ..._subItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final subItem = entry.value;
                              return Card(
                                child: ListTile(
                                  title: Text(subItem.description),
                                  subtitle: Text(
                                    widget.currencyFormat.format(
                                      subItem.amount,
                                    ),
                                  ),
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        tooltip: l10n.editSubItemAction,
                                        onPressed: () =>
                                            _addOrEditSubItem(index: index),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: l10n.deletePurchaseAction,
                                        onPressed: () {
                                          setState(() {
                                            _subItems.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            if (_subItems.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _amountController.text = subItemsTotal
                                          .toStringAsFixed(2);
                                    });
                                  },
                                  child: Text(l10n.applySubItemsTotalAction),
                                ),
                              ),
                          ],
                        ),
                        ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              l10n.notesLabel,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _notesController,
                              decoration: InputDecoration(
                                labelText: l10n.notesLabel,
                              ),
                              minLines: 6,
                              maxLines: 10,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
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
                                onPressed: _currentStep == 0
                                    ? null
                                    : () {
                                        _pageController.previousPage(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(l10n.stepBackAction),
                              ),
                            ),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _currentStep == 2
                                    ? null
                                    : () {
                                        _pageController.nextPage(
                                          duration: const Duration(
                                            milliseconds: 220,
                                          ),
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
                                onPressed: _requestClose,
                                child: Text(l10n.cancelAction),
                              ),
                            ),
                            Expanded(
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _descriptionController,
                                builder: (context, descriptionValue, child) {
                                  return ValueListenableBuilder<
                                    TextEditingValue
                                  >(
                                    valueListenable: _amountController,
                                    builder: (context, amountValue, child) {
                                      final hasMinimumDetails =
                                          _descriptionController.text
                                              .trim()
                                              .isNotEmpty &&
                                          _amountController.text
                                              .trim()
                                              .isNotEmpty;
                                      return FilledButton.icon(
                                        onPressed: hasMinimumDetails
                                            ? _submitForm
                                            : null,
                                        icon: Icon(
                                          widget.item == null
                                              ? Icons.add
                                              : Icons.save,
                                        ),
                                        label: Text(
                                          widget.item == null
                                              ? l10n.addPurchase
                                              : l10n.savePurchaseAction,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

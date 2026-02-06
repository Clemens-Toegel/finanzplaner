import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/purchase_repository.dart';
import '../gen/app_localizations.dart';
import '../localization/app_localizations_ext.dart';
import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/expense_sub_item.dart';
import '../models/ocr_bill_data.dart';
import '../models/purchase_item.dart';
import '../screens/purchase_detail_page.dart';
import '../services/offline_bill_ocr_service.dart';
import '../services/pdf_exporter.dart';
import '../widgets/info_chip.dart';

class PurchaseHomePage extends StatefulWidget {
  const PurchaseHomePage({super.key});

  @override
  State<PurchaseHomePage> createState() => _PurchaseHomePageState();
}

class _PurchaseHomePageState extends State<PurchaseHomePage> {
  final PurchaseRepository _repository = PurchaseRepository();
  final PdfExporter _pdfExporter = PdfExporter();
  final OfflineBillOcrService _offlineBillOcrService = OfflineBillOcrService();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'de_AT',
    symbol: '€',
  );

  ExpenseAccountType _selectedAccount = ExpenseAccountType.business;
  List<PurchaseItem> _items = [];
  bool _isLoading = true;
  Map<ExpenseAccountType, AccountSettings> _accountSettings = {
    ExpenseAccountType.personal: const AccountSettings(
      accountType: ExpenseAccountType.personal,
    ),
    ExpenseAccountType.business: const AccountSettings(
      accountType: ExpenseAccountType.business,
    ),
  };

  double get _totalAmount =>
      _items.fold(0, (total, item) => total + item.amount);

  double get _deductibleAmount => _items
      .where((item) => item.isDeductible)
      .fold(0, (total, item) => total + item.amount);

  double get _nonDeductibleAmount => _totalAmount - _deductibleAmount;

  Map<String, double> get _categoryTotals {
    final totals = <String, double>{};
    for (final item in _items) {
      totals.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    return totals;
  }

  int _selectedTabIndex = 0;

  Color _accountColor(BuildContext context) {
    return _selectedAccount == ExpenseAccountType.business
        ? Colors.blue
        : Colors.orange;
  }

  @override
  void initState() {
    super.initState();
    _loadAccountSettings();
    _loadItems();
  }

  @override
  void dispose() {
    _offlineBillOcrService.dispose();
    super.dispose();
  }

  List<PurchaseItem> _sortItemsByDate(List<PurchaseItem> items) {
    final sorted = List<PurchaseItem>.from(items)
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) {
          return byDate;
        }
        return (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return sorted;
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    final items = await _repository.fetchPurchases(_selectedAccount);
    if (!mounted) {
      return;
    }
    setState(() {
      _items = _sortItemsByDate(items);
      _isLoading = false;
    });
  }

  Future<void> _loadAccountSettings() async {
    final settings = await _repository.fetchAccountSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _accountSettings = settings;
    });
  }

  Future<void> _exportPdf() async {
    final l10n = AppLocalizations.of(context)!;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addBeforeExport)));
      return;
    }

    await _pdfExporter.exportPurchases(
      account: _selectedAccount,
      items: _items,
      localizations: l10n,
      accountSettings: _accountSettings[_selectedAccount],
    );
  }

  void _openAccountSettingsSheet() {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();

    ExpenseAccountType editingAccount = _selectedAccount;
    final personalNameController = TextEditingController(
      text: _accountSettings[ExpenseAccountType.personal]?.displayName ?? '',
    );
    final businessNameController = TextEditingController(
      text: _accountSettings[ExpenseAccountType.business]?.displayName ?? '',
    );
    final firmenbuchnummerController = TextEditingController(
      text:
          _accountSettings[ExpenseAccountType.business]
              ?.companyRegisterNumber ??
          '',
    );

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isBusiness = editingAccount == ExpenseAccountType.business;
            final currentNameController = isBusiness
                ? businessNameController
                : personalNameController;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
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
                        initialValue: editingAccount,
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
                          setModalState(() {
                            editingAccount = value;
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
                          controller: firmenbuchnummerController,
                          decoration: InputDecoration(
                            labelText: l10n.firmenbuchnummerLabel,
                          ),
                          validator: (value) {
                            final text = (value ?? '').trim();
                            if (text.isEmpty) {
                              return null;
                            }
                            if (!RegExp(
                              r'^[A-Za-z0-9\-\s/]+$',
                            ).hasMatch(text)) {
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
                              final navigator = Navigator.of(context);
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final personalSettings = AccountSettings(
                                accountType: ExpenseAccountType.personal,
                                displayName: personalNameController.text.trim(),
                              );
                              final businessSettings = AccountSettings(
                                accountType: ExpenseAccountType.business,
                                displayName: businessNameController.text.trim(),
                                companyRegisterNumber:
                                    firmenbuchnummerController.text.trim(),
                              );

                              await _repository.saveAccountSettings(
                                personalSettings,
                              );
                              await _repository.saveAccountSettings(
                                businessSettings,
                              );

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _accountSettings = {
                                  ExpenseAccountType.personal: personalSettings,
                                  ExpenseAccountType.business: businessSettings,
                                };
                              });

                              navigator.pop();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.accountSettingsSavedMessage,
                                  ),
                                ),
                              );
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
      },
    );
  }

  void _openAddItemSheet({PurchaseItem? item}) {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final vendorController = TextEditingController(text: item?.vendor ?? '');
    final amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    final notesController = TextEditingController(text: item?.notes ?? '');
    final categories = l10n.categoriesForAccount(_selectedAccount);

    DateTime selectedDate = item?.date ?? DateTime.now();
    String selectedCategory = item?.category ?? categories.first;
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }
    bool isDeductible = item?.isDeductible ?? true;
    bool isScanning = false;
    int currentStep = 0;
    final pageController = PageController(initialPage: 0);
    final subItems = List<ExpenseSubItem>.from(item?.subItems ?? const []);

    final initialDescription = descriptionController.text.trim();
    final initialVendor = vendorController.text.trim();
    final initialAmount = amountController.text.trim();
    final initialNotes = notesController.text.trim();
    final initialCategory = selectedCategory;
    final initialDate = selectedDate;
    final initialIsDeductible = isDeductible;
    final initialSubItems = List<ExpenseSubItem>.from(subItems);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      builder: (context) {
        Future<void> submitForm() async {
          final navigator = Navigator.of(context);
          if (amountController.text.trim().isEmpty && subItems.isNotEmpty) {
            final sum = subItems.fold<double>(
              0,
              (total, subItem) => total + subItem.amount,
            );
            amountController.text = sum.toStringAsFixed(2);
          }

          final hasMinimumDetails =
              descriptionController.text.trim().isNotEmpty &&
              amountController.text.trim().isNotEmpty;

          if (!hasMinimumDetails) {
            if (currentStep != 0) {
              await pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            }
            formKey.currentState!.validate();
            return;
          }

          if (!formKey.currentState!.validate()) {
            if (currentStep != 0) {
              await pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            }
            return;
          }
          final parsedAmount = double.parse(
            amountController.text.replaceAll(',', '.'),
          );

          final subItemsSum = subItems.fold<double>(
            0,
            (total, subItem) => total + subItem.amount,
          );
          final hasSubItemAboveTotal = subItems.any(
            (subItem) => subItem.amount > parsedAmount,
          );

          if (hasSubItemAboveTotal || subItemsSum > parsedAmount) {
            if (currentStep != 1) {
              await pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            }
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text(l10n.subItemsExceedTotalValidation)),
            );
            return;
          }

          final updatedItem = PurchaseItem(
            id: item?.id,
            accountType: _selectedAccount,
            description: descriptionController.text.trim(),
            vendor: vendorController.text.trim(),
            category: selectedCategory,
            amount: parsedAmount,
            date: selectedDate,
            isDeductible: isDeductible,
            notes: notesController.text.trim(),
            subItems: subItems,
          );
          if (item == null) {
            final savedItem = await _repository.insertPurchase(updatedItem);
            if (!mounted) {
              return;
            }
            setState(() {
              _items = _sortItemsByDate([savedItem, ..._items]);
            });
          } else {
            await _repository.updatePurchase(updatedItem);
            if (!mounted) {
              return;
            }
            setState(() {
              final index = _items.indexWhere(
                (existing) => existing.id == updatedItem.id,
              );
              if (index != -1) {
                _items = _sortItemsByDate(
                  List.from(_items)..[index] = updatedItem,
                );
              }
            });
          }
          navigator.pop();
        }

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
            child: StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> scanBill(
                  BillScanMode mode, {
                  BillImageSource source = BillImageSource.camera,
                }) async {
                  if (isScanning) {
                    return;
                  }

                  setModalState(() {
                    isScanning = true;
                  });

                  try {
                    final data = await _offlineBillOcrService.scanBill(
                      mode: mode,
                      source: source,
                    );
                    if (!mounted) {
                      return;
                    }

                    if (data == null) {
                      return;
                    }

                    if (data.rawText.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(l10n.ocrNoTextFound)),
                      );
                      return;
                    }

                    setModalState(() {
                      _applyOcrDataToForm(
                        data,
                        descriptionController: descriptionController,
                        vendorController: vendorController,
                        amountController: amountController,
                        notesController: notesController,
                        selectedDateSetter: (date) => selectedDate = date,
                        subItemsSetter: (items) {
                          subItems
                            ..clear()
                            ..addAll(items);
                        },
                      );
                    });

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text(l10n.ocrAppliedMessage)),
                    );
                  } catch (_) {
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text(l10n.ocrErrorMessage)),
                    );
                  } finally {
                    if (mounted) {
                      setModalState(() {
                        isScanning = false;
                      });
                    }
                  }
                }

                Future<void> scanA4Bill() async {
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
                              onTap: () => Navigator.pop(
                                context,
                                BillImageSource.camera,
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_outlined),
                              title: Text(l10n.scanFromGalleryAction),
                              onTap: () => Navigator.pop(
                                context,
                                BillImageSource.gallery,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (source == null) {
                    return;
                  }

                  await scanBill(BillScanMode.a4Bill, source: source);
                }

                Future<void> addOrEditSubItem({int? index}) async {
                  final existing = index != null ? subItems[index] : null;
                  final totalAmount = double.tryParse(
                    amountController.text.replaceAll(',', '.'),
                  );
                  final allocatedWithoutCurrent =
                      subItems.fold<double>(
                        0,
                        (total, subItem) => total + subItem.amount,
                      ) -
                      (existing?.amount ?? 0);

                  if (index == null &&
                      totalAmount != null &&
                      allocatedWithoutCurrent >= totalAmount) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.subItemsExceedTotalValidation),
                      ),
                    );
                    return;
                  }

                  final subItemDescriptionController = TextEditingController(
                    text: existing?.description ?? '',
                  );
                  final subItemAmountController = TextEditingController(
                    text: existing != null
                        ? existing.amount.toStringAsFixed(2)
                        : '',
                  );

                  final added = await showDialog<ExpenseSubItem>(
                    context: context,
                    builder: (context) {
                      final dialogFormKey = GlobalKey<FormState>();
                      return AlertDialog(
                        title: Text(
                          existing == null
                              ? l10n.addSubItemAction
                              : l10n.editSubItemAction,
                        ),
                        content: Form(
                          key: dialogFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              TextFormField(
                                controller: subItemDescriptionController,
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
                              TextFormField(
                                controller: subItemAmountController,
                                decoration: InputDecoration(
                                  labelText: l10n.amountLabel,
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

                                  if (totalAmount != null) {
                                    if (parsed > totalAmount) {
                                      return l10n
                                          .subItemAmountExceedsTotalValidation;
                                    }
                                    if (allocatedWithoutCurrent + parsed >
                                        totalAmount) {
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
                                subItemAmountController.text.replaceAll(
                                  ',',
                                  '.',
                                ),
                              );

                              Navigator.pop(
                                context,
                                ExpenseSubItem(
                                  description: subItemDescriptionController.text
                                      .trim(),
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

                  final candidateSubItems = List<ExpenseSubItem>.from(subItems);
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
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.subItemsExceedTotalValidation),
                        ),
                      );
                      return;
                    }
                  }

                  setModalState(() {
                    if (index == null) {
                      subItems.add(added);
                    } else {
                      subItems[index] = added;
                    }
                  });
                }

                bool hasUnsavedChanges() {
                  if (descriptionController.text.trim() != initialDescription) {
                    return true;
                  }
                  if (vendorController.text.trim() != initialVendor) {
                    return true;
                  }
                  if (amountController.text.trim() != initialAmount) {
                    return true;
                  }
                  if (notesController.text.trim() != initialNotes) {
                    return true;
                  }
                  if (selectedCategory != initialCategory) {
                    return true;
                  }
                  if (selectedDate != initialDate) {
                    return true;
                  }
                  if (isDeductible != initialIsDeductible) {
                    return true;
                  }
                  if (subItems.length != initialSubItems.length) {
                    return true;
                  }
                  for (var i = 0; i < subItems.length; i++) {
                    final current = subItems[i];
                    final initial = initialSubItems[i];
                    if (current.description != initial.description ||
                        current.amount != initial.amount) {
                      return true;
                    }
                  }
                  return false;
                }

                Future<void> requestClose() async {
                  final navigator = Navigator.of(context);
                  if (!hasUnsavedChanges()) {
                    navigator.pop();
                    return;
                  }

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
                    navigator.pop();
                  }
                }

                final subItemsTotal = subItems.fold<double>(
                  0,
                  (total, entry) => total + entry.amount,
                );
                final totalAmountValue = double.tryParse(
                  amountController.text.replaceAll(',', '.'),
                );
                final remainingForSubItems = totalAmountValue != null
                    ? (totalAmountValue - subItemsTotal)
                    : null;
                final canAddSubItem =
                    remainingForSubItems == null || remainingForSubItems > 0;
                final subItemsOverAllocated =
                    remainingForSubItems != null && remainingForSubItems < 0;

                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) {
                      requestClose();
                    }
                  },
                  child: Form(
                    key: formKey,
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
                              color: _accountColor(
                                context,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _accountColor(
                                  context,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
                              children: [
                                Icon(
                                  _selectedAccount ==
                                          ExpenseAccountType.business
                                      ? Icons.business
                                      : Icons.person,
                                  color: _accountColor(context),
                                ),
                                Text(
                                  l10n.accountLabel(_selectedAccount),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: _accountColor(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: Text(
                              item == null
                                  ? l10n.addPurchaseTitle
                                  : l10n.editPurchaseTitle,
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 8,
                                width: isActive ? 22 : 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? _accountColor(context)
                                      : Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: PageView(
                              controller: pageController,
                              onPageChanged: (index) {
                                setModalState(() {
                                  currentStep = index;
                                });
                              },
                              children: [
                                ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    Text(
                                      l10n.offlineOcrPrivacyNote,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: isScanning
                                                ? null
                                                : () => scanBill(
                                                    BillScanMode.shopReceipt,
                                                  ),
                                            icon: const Icon(
                                              Icons.receipt_long,
                                            ),
                                            label: Text(l10n.scanReceiptAction),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: isScanning
                                                ? null
                                                : scanA4Bill,
                                            icon: const Icon(
                                              Icons.document_scanner_outlined,
                                            ),
                                            label: Text(
                                              l10n.scanDocumentAction,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isScanning) ...[
                                      const SizedBox(height: 12),
                                      const LinearProgressIndicator(),
                                    ],
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: descriptionController,
                                      decoration: InputDecoration(
                                        labelText: l10n.descriptionLabel,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return l10n.descriptionValidation;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: vendorController,
                                      decoration: InputDecoration(
                                        labelText: l10n.vendorLabel,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: amountController,
                                      decoration: InputDecoration(
                                        labelText: l10n.amountLabel,
                                        helperText: subItems.isNotEmpty
                                            ? l10n.subItemsSumHint(
                                                _currencyFormat.format(
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
                                        if (value == null ||
                                            value.trim().isEmpty) {
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
                                      initialValue: selectedCategory,
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
                                        setModalState(() {
                                          selectedCategory = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 4),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(l10n.dateOfPurchaseLabel),
                                      subtitle: Text(
                                        _dateFormat.format(selectedDate),
                                      ),
                                      trailing: TextButton.icon(
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: selectedDate,
                                            firstDate: DateTime(2015),
                                            lastDate: DateTime.now(),
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              selectedDate = picked;
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
                                      value: isDeductible,
                                      onChanged: (value) {
                                        setModalState(() {
                                          isDeductible = value;
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Card(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(l10n.subItemsTotalLabel),
                                                Text(
                                                  _currencyFormat.format(
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  l10n.remainingForSubItemsLabel,
                                                ),
                                                Text(
                                                  remainingForSubItems == null
                                                      ? '—'
                                                      : _currencyFormat.format(
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
                                          ? () => addOrEditSubItem()
                                          : null,
                                      icon: const Icon(Icons.add),
                                      label: Text(l10n.addSubItemAction),
                                    ),
                                    const SizedBox(height: 10),
                                    if (subItemsOverAllocated)
                                      Text(
                                        l10n.subItemsExceedTotalValidation,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                      ),
                                    if (subItems.isEmpty)
                                      Text(
                                        l10n.noSubItemsYet,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ...subItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final subItem = entry.value;
                                      return Card(
                                        child: ListTile(
                                          title: Text(subItem.description),
                                          subtitle: Text(
                                            _currencyFormat.format(
                                              subItem.amount,
                                            ),
                                          ),
                                          trailing: Wrap(
                                            spacing: 4,
                                            children: [
                                              IconButton(
                                                tooltip: l10n.editSubItemAction,
                                                onPressed: () =>
                                                    addOrEditSubItem(
                                                      index: index,
                                                    ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                              ),
                                              IconButton(
                                                tooltip:
                                                    l10n.deletePurchaseAction,
                                                onPressed: () {
                                                  setModalState(() {
                                                    subItems.removeAt(index);
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    if (subItems.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            setModalState(() {
                                              amountController.text =
                                                  subItemsTotal.toStringAsFixed(
                                                    2,
                                                  );
                                            });
                                          },
                                          child: Text(
                                            l10n.applySubItemsTotalAction,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  children: [
                                    Text(
                                      l10n.notesLabel,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: notesController,
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
                                        onPressed: currentStep == 0
                                            ? null
                                            : () {
                                                pageController.previousPage(
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeOut,
                                                );
                                              },
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                        ),
                                        label: Text(l10n.stepBackAction),
                                      ),
                                    ),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: currentStep == 2
                                            ? null
                                            : () {
                                                pageController.nextPage(
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeOut,
                                                );
                                              },
                                        icon: const Icon(
                                          Icons.arrow_forward_rounded,
                                        ),
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
                                        onPressed: requestClose,
                                        child: Text(l10n.cancelAction),
                                      ),
                                    ),
                                    Expanded(
                                      child: ValueListenableBuilder<TextEditingValue>(
                                        valueListenable: descriptionController,
                                        builder:
                                            (context, descriptionValue, child) {
                                              return ValueListenableBuilder<
                                                TextEditingValue
                                              >(
                                                valueListenable:
                                                    amountController,
                                                builder:
                                                    (
                                                      context,
                                                      amountValue,
                                                      child,
                                                    ) {
                                                      final hasMinimumDetails =
                                                          descriptionController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty &&
                                                          amountController.text
                                                              .trim()
                                                              .isNotEmpty;
                                                      return FilledButton.icon(
                                                        onPressed:
                                                            hasMinimumDetails
                                                            ? submitForm
                                                            : null,
                                                        icon: Icon(
                                                          item == null
                                                              ? Icons.add
                                                              : Icons.save,
                                                        ),
                                                        label: Text(
                                                          item == null
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _applyOcrDataToForm(
    OcrBillData data, {
    required TextEditingController descriptionController,
    required TextEditingController vendorController,
    required TextEditingController amountController,
    required TextEditingController notesController,
    required ValueChanged<DateTime> selectedDateSetter,
    required ValueChanged<List<ExpenseSubItem>> subItemsSetter,
  }) {
    if (data.description != null && data.description!.trim().isNotEmpty) {
      descriptionController.text = data.description!.trim();
    }
    if (data.vendor != null && data.vendor!.trim().isNotEmpty) {
      vendorController.text = data.vendor!.trim();
    }
    if (data.amount != null && data.amount! > 0) {
      amountController.text = data.amount!.toStringAsFixed(2);
    }
    if (data.date != null) {
      selectedDateSetter(data.date!);
    }
    if (data.subItems.isNotEmpty) {
      subItemsSetter(data.subItems);
      if (data.amount == null || data.amount! <= 0) {
        final sum = data.subItems.fold<double>(
          0,
          (total, subItem) => total + subItem.amount,
        );
        if (sum > 0) {
          amountController.text = sum.toStringAsFixed(2);
        }
      }
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Icon(
                Icons.receipt_long,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              l10n.emptyStateTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.emptyStateSubtitle(
                l10n.accountLabelInSentence(_selectedAccount),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: ListTile(
          leading: const Icon(Icons.summarize),
          title: Text(l10n.deductibleTotalLabel),
          subtitle: Text(l10n.itemsTracked(_items.length)),
          trailing: Text(
            _currencyFormat.format(_deductibleAmount),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  List<_MonthSection> _groupItemsByMonth() {
    final sections = <_MonthSection>[];
    for (final item in _items) {
      if (sections.isEmpty ||
          sections.last.month.year != item.date.year ||
          sections.last.month.month != item.date.month) {
        sections.add(
          _MonthSection(
            month: DateTime(item.date.year, item.date.month),
            items: [item],
          ),
        );
      } else {
        sections.last.items.add(item);
      }
    }
    return sections;
  }

  Widget _buildExpenseCard(PurchaseItem item, AppLocalizations l10n) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final action = await Navigator.push<PurchaseDetailAction>(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseDetailPage(item: item),
            ),
          );
          if (!mounted) {
            return;
          }
          if (action == PurchaseDetailAction.edit) {
            _openAddItemSheet(item: item);
          }
          if (action == PurchaseDetailAction.delete && item.id != null) {
            await _repository.deletePurchase(item.id!);
            if (!mounted) {
              return;
            }
            setState(() {
              _items = _items
                  .where((existing) => existing.id != item.id)
                  .toList();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                item.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${item.vendor.isEmpty ? l10n.unknownVendor : item.vendor} • ${item.category}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    InfoChip(
                      icon: Icons.calendar_today,
                      label: _dateFormat.format(item.date),
                    ),
                    InfoChip(
                      icon: Icons.euro,
                      label: _currencyFormat.format(item.amount),
                    ),
                    InfoChip(
                      icon: item.isDeductible
                          ? Icons.check_circle
                          : Icons.info_outline,
                      label: item.isDeductible
                          ? l10n.deductibleLabel
                          : l10n.notDeductibleLabel,
                    ),
                    if (item.subItems.isNotEmpty)
                      InfoChip(
                        icon: Icons.format_list_bulleted,
                        label: l10n.subItemsCountLabel(item.subItems.length),
                      ),
                  ],
                ),
              ),
              if (item.notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    item.notes,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(AppLocalizations l10n) {
    if (_items.isEmpty) {
      return _buildEmptyState(l10n);
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final categoryTotals = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = categoryTotals.take(5).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 96 + bottomInset),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DashboardMetricCard(
              title: l10n.totalAmountLabel,
              value: _currencyFormat.format(_totalAmount),
              icon: Icons.account_balance_wallet,
            ),
            _DashboardMetricCard(
              title: l10n.deductibleTotalLabel,
              value: _currencyFormat.format(_deductibleAmount),
              icon: Icons.check_circle,
            ),
            _DashboardMetricCard(
              title: l10n.nonDeductibleTotalLabel,
              value: _currencyFormat.format(_nonDeductibleAmount),
              icon: Icons.remove_circle_outline,
            ),
            _DashboardMetricCard(
              title: l10n.averageExpenseLabel,
              value: _currencyFormat.format(_totalAmount / _items.length),
              icon: Icons.analytics,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text(
                    l10n.topCategoriesLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...topCategories.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(child: Text(entry.key)),
                          Text(_currencyFormat.format(entry.value)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab(AppLocalizations l10n) {
    if (_items.isEmpty) {
      return _buildEmptyState(l10n);
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final monthFormat = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    );
    final sections = _groupItemsByMonth();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummary(l10n)),
        for (
          var sectionIndex = 0;
          sectionIndex < sections.length;
          sectionIndex++
        )
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _MonthHeaderDelegate(
                  title: monthFormat.format(sections[sectionIndex].month),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: sections[sectionIndex].items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = sections[sectionIndex].items[itemIndex];
                    final isLastInSection =
                        itemIndex == sections[sectionIndex].items.length - 1;
                    final isLastSection = sectionIndex == sections.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLastInSection && isLastSection ? 0 : 12,
                      ),
                      child: _buildExpenseCard(item, l10n),
                    );
                  },
                ),
              ),
            ],
          ),
        SliverToBoxAdapter(child: SizedBox(height: 96 + bottomInset)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxRefundPurchasesTitle),
        actions: [
          IconButton(
            tooltip: l10n.accountSettingsTitle,
            onPressed: _openAccountSettingsSheet,
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.exportPdfTooltip,
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accountColor(context).withValues(alpha: 0.18),
                    _accountColor(context).withValues(alpha: 0.06),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _accountColor(context).withValues(alpha: 0.35),
                ),
              ),
              child: DropdownButtonFormField<ExpenseAccountType>(
                initialValue: _selectedAccount,
                decoration: InputDecoration(
                  labelText: l10n.expenseAccountLabel,
                  prefixIcon: Icon(
                    _selectedAccount == ExpenseAccountType.business
                        ? Icons.business
                        : Icons.person,
                    color: _accountColor(context),
                  ),
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
                    _selectedAccount = value;
                  });
                  _loadItems();
                },
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _selectedTabIndex == 0
              ? _buildExpensesTab(l10n)
              : _buildDashboard(l10n),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.expensesTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n.dashboardTabLabel,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddItemSheet(),
        backgroundColor: _accountColor(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(l10n.addPurchase),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSection {
  _MonthSection({required this.month, required this.items});

  final DateTime month;
  final List<PurchaseItem> items;
}

class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  _MonthHeaderDelegate({required this.title});

  final String title;

  @override
  double get minExtent => 36;

  @override
  double get maxExtent => 36;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate oldDelegate) {
    return oldDelegate.title != title;
  }
}

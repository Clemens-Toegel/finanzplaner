import 'package:flutter/material.dart';

import '../models/expense_account_type.dart';
import '../models/expense_sub_item.dart';
import '../models/ocr_bill_data.dart';
import '../models/purchase_item.dart';

class AddEditPurchaseController extends ChangeNotifier {
  AddEditPurchaseController({
    required this.selectedAccount,
    required this.categories,
    this.item,
  }) {
    descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    vendorController = TextEditingController(text: item?.vendor ?? '');
    amountController = TextEditingController(
      text: item != null ? item!.amount.toStringAsFixed(2) : '',
    );
    notesController = TextEditingController(text: item?.notes ?? '');
    pageController = PageController(initialPage: 0);

    selectedDate = item?.date ?? DateTime.now();
    selectedCategory = item?.category ?? categories.first;
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }
    isDeductible = item?.isDeductible ?? true;
    subItems = List<ExpenseSubItem>.from(item?.subItems ?? const []);

    initialDescription = descriptionController.text.trim();
    initialVendor = vendorController.text.trim();
    initialAmount = amountController.text.trim();
    initialNotes = notesController.text.trim();
    initialCategory = selectedCategory;
    initialDate = selectedDate;
    initialIsDeductible = isDeductible;
    initialSubItems = List<ExpenseSubItem>.from(subItems);
  }

  final ExpenseAccountType selectedAccount;
  final List<String> categories;
  final PurchaseItem? item;

  late final TextEditingController descriptionController;
  late final TextEditingController vendorController;
  late final TextEditingController amountController;
  late final TextEditingController notesController;
  late final PageController pageController;

  late DateTime selectedDate;
  late String selectedCategory;
  late bool isDeductible;
  bool isScanning = false;
  int currentStep = 0;
  late List<ExpenseSubItem> subItems;

  late final String initialDescription;
  late final String initialVendor;
  late final String initialAmount;
  late final String initialNotes;
  late final String initialCategory;
  late final DateTime initialDate;
  late final bool initialIsDeductible;
  late final List<ExpenseSubItem> initialSubItems;

  double get subItemsTotal =>
      subItems.fold(0, (total, item) => total + item.amount);

  double? get totalAmountValue =>
      double.tryParse(amountController.text.replaceAll(',', '.'));

  double? get remainingForSubItems =>
      totalAmountValue != null ? totalAmountValue! - subItemsTotal : null;

  bool get canAddSubItem =>
      remainingForSubItems == null || remainingForSubItems! > 0;

  bool get subItemsOverAllocated =>
      remainingForSubItems != null && remainingForSubItems! < 0;

  bool get hasMinimumDetails =>
      descriptionController.text.trim().isNotEmpty &&
      amountController.text.trim().isNotEmpty;

  void setCurrentStep(int value) {
    if (currentStep == value) {
      return;
    }
    currentStep = value;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    if (selectedCategory == value) {
      return;
    }
    selectedCategory = value;
    notifyListeners();
  }

  void setSelectedDate(DateTime value) {
    selectedDate = value;
    notifyListeners();
  }

  void setIsDeductible(bool value) {
    if (isDeductible == value) {
      return;
    }
    isDeductible = value;
    notifyListeners();
  }

  void setScanning(bool value) {
    if (isScanning == value) {
      return;
    }
    isScanning = value;
    notifyListeners();
  }

  void setSubItems(List<ExpenseSubItem> value) {
    subItems = List<ExpenseSubItem>.from(value);
    notifyListeners();
  }

  void upsertSubItem(ExpenseSubItem value, {int? index}) {
    final updated = List<ExpenseSubItem>.from(subItems);
    if (index == null) {
      updated.add(value);
    } else {
      updated[index] = value;
    }
    subItems = updated;
    notifyListeners();
  }

  void removeSubItemAt(int index) {
    final updated = List<ExpenseSubItem>.from(subItems)..removeAt(index);
    subItems = updated;
    notifyListeners();
  }

  void applySubItemsTotalToAmount() {
    amountController.text = subItemsTotal.toStringAsFixed(2);
    notifyListeners();
  }

  void applyOcrDataToForm(OcrBillData data) {
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
      selectedDate = data.date!;
    }
    if (data.subItems.isNotEmpty) {
      subItems = List<ExpenseSubItem>.from(data.subItems);
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
    notifyListeners();
  }

  void ensureAmountFromSubItemsIfMissing() {
    if (amountController.text.trim().isEmpty && subItems.isNotEmpty) {
      amountController.text = subItemsTotal.toStringAsFixed(2);
    }
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

  PurchaseItem? tryBuildDraft() {
    final parsedAmount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );
    if (parsedAmount == null || parsedAmount <= 0) {
      return null;
    }

    return PurchaseItem(
      id: item?.id,
      accountType: selectedAccount,
      description: descriptionController.text.trim(),
      vendor: vendorController.text.trim(),
      category: selectedCategory,
      amount: parsedAmount,
      date: selectedDate,
      isDeductible: isDeductible,
      notes: notesController.text.trim(),
      subItems: subItems,
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    vendorController.dispose();
    amountController.dispose();
    notesController.dispose();
    pageController.dispose();
    super.dispose();
  }
}

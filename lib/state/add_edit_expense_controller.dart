import 'package:flutter/material.dart';

import '../models/expense_account_type.dart';
import '../models/expense_sub_item.dart';
import '../models/ocr_bill_data.dart';
import '../models/expense_item.dart';

class AddEditExpenseController extends ChangeNotifier {
  AddEditExpenseController({
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

    attachmentPath = item?.attachmentPath;
    secondaryAttachmentPaths = List<String>.from(
      item?.secondaryAttachmentPaths ?? const [],
    );
    secondaryAttachmentNames = List<String>.from(
      item?.secondaryAttachmentNames ?? const [],
    );
    _normalizeSecondaryAttachmentNames();

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
    initialAttachmentPath = (attachmentPath ?? '').trim();
    initialSecondaryAttachmentPaths = List<String>.from(
      secondaryAttachmentPaths,
    );
    initialSecondaryAttachmentNames = List<String>.from(
      secondaryAttachmentNames,
    );
    initialCategory = selectedCategory;
    initialDate = selectedDate;
    initialIsDeductible = isDeductible;
    initialSubItems = List<ExpenseSubItem>.from(subItems);
  }

  final ExpenseAccountType selectedAccount;
  final List<String> categories;
  final ExpenseItem? item;

  late final TextEditingController descriptionController;
  late final TextEditingController vendorController;
  late final TextEditingController amountController;
  late final TextEditingController notesController;

  late DateTime selectedDate;
  late String selectedCategory;
  late bool isDeductible;
  bool isScanning = false;
  String? attachmentPath;
  List<String> secondaryAttachmentPaths = <String>[];
  List<String> secondaryAttachmentNames = <String>[];
  String? pendingAttachmentSourcePath;
  late List<ExpenseSubItem> subItems;

  late final String initialDescription;
  late final String initialVendor;
  late final String initialAmount;
  late final String initialNotes;
  late final String initialAttachmentPath;
  late final List<String> initialSecondaryAttachmentPaths;
  late final List<String> initialSecondaryAttachmentNames;
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

  bool get hasAttachment =>
      (attachmentPath != null && attachmentPath!.trim().isNotEmpty) ||
      (pendingAttachmentSourcePath != null &&
          pendingAttachmentSourcePath!.trim().isNotEmpty);

  int get secondaryAttachmentCount => secondaryAttachmentPaths.length;

  String secondaryAttachmentNameAt(int index) {
    if (index < 0 || index >= secondaryAttachmentNames.length) {
      return 'Bild';
    }
    return secondaryAttachmentNames[index];
  }

  void addSecondaryAttachmentPath(String sourcePath, {String? name}) {
    final path = sourcePath.trim();
    if (path.isEmpty || secondaryAttachmentPaths.contains(path)) {
      return;
    }
    secondaryAttachmentPaths = [...secondaryAttachmentPaths, path];
    secondaryAttachmentNames = [
      ...secondaryAttachmentNames,
      (name ?? _defaultNameFromPath(path)).trim().isEmpty
          ? _defaultNameFromPath(path)
          : (name ?? _defaultNameFromPath(path)).trim(),
    ];
    _normalizeSecondaryAttachmentNames();
    notifyListeners();
  }

  void removeSecondaryAttachmentAt(int index) {
    if (index < 0 || index >= secondaryAttachmentPaths.length) {
      return;
    }
    final updatedPaths = List<String>.from(secondaryAttachmentPaths)
      ..removeAt(index);
    final updatedNames = List<String>.from(secondaryAttachmentNames)
      ..removeAt(index);
    secondaryAttachmentPaths = updatedPaths;
    secondaryAttachmentNames = updatedNames;
    notifyListeners();
  }

  void moveSecondaryAttachment(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= secondaryAttachmentPaths.length) {
      return;
    }
    if (newIndex < 0 || newIndex >= secondaryAttachmentPaths.length) {
      return;
    }
    if (oldIndex == newIndex) {
      return;
    }

    final updatedPaths = List<String>.from(secondaryAttachmentPaths);
    final movedPath = updatedPaths.removeAt(oldIndex);
    updatedPaths.insert(newIndex, movedPath);

    final updatedNames = List<String>.from(secondaryAttachmentNames);
    final movedName = updatedNames.removeAt(oldIndex);
    updatedNames.insert(newIndex, movedName);

    secondaryAttachmentPaths = updatedPaths;
    secondaryAttachmentNames = updatedNames;
    notifyListeners();
  }

  void renameSecondaryAttachment(int index, String name) {
    if (index < 0 || index >= secondaryAttachmentNames.length) {
      return;
    }
    final trimmed = name.trim();
    final updated = List<String>.from(secondaryAttachmentNames);
    updated[index] = trimmed.isEmpty
        ? _defaultNameFromPath(secondaryAttachmentPaths[index])
        : trimmed;
    secondaryAttachmentNames = updated;
    notifyListeners();
  }

  String _defaultNameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/').trim();
    if (normalized.isEmpty) {
      return 'Bild';
    }
    final parts = normalized
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Bild' : parts.last;
  }

  void _normalizeSecondaryAttachmentNames() {
    if (secondaryAttachmentPaths.isEmpty) {
      secondaryAttachmentNames = <String>[];
      return;
    }

    final normalized = <String>[];
    for (var i = 0; i < secondaryAttachmentPaths.length; i++) {
      final existing = i < secondaryAttachmentNames.length
          ? secondaryAttachmentNames[i].trim()
          : '';
      normalized.add(
        existing.isEmpty
            ? _defaultNameFromPath(secondaryAttachmentPaths[i])
            : existing,
      );
    }
    secondaryAttachmentNames = normalized;
  }

  void setPendingAttachmentSourcePath(String? sourcePath) {
    pendingAttachmentSourcePath = sourcePath?.trim();
    notifyListeners();
  }

  void setAttachmentPath(String? path) {
    attachmentPath = path?.trim();
    notifyListeners();
  }

  void clearPendingAttachmentSourcePath() {
    pendingAttachmentSourcePath = null;
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
    _syncAmountWithSubItems();
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
    _syncAmountWithSubItems();
    notifyListeners();
  }

  void removeSubItemAt(int index) {
    final updated = List<ExpenseSubItem>.from(subItems)..removeAt(index);
    subItems = updated;
    _syncAmountWithSubItems();
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
      _syncAmountWithSubItems();
      if (data.amount != null && data.amount! > 0) {
        amountController.text = data.amount!.toStringAsFixed(2);
        _syncAmountWithSubItems();
      }
    }
    if (data.sourceFilePath != null && data.sourceFilePath!.trim().isNotEmpty) {
      pendingAttachmentSourcePath = data.sourceFilePath!.trim();
    }
    notifyListeners();
  }

  void ensureAmountFromSubItemsIfMissing() {
    _syncAmountWithSubItems();
  }

  void _syncAmountWithSubItems() {
    if (subItems.isEmpty) {
      return;
    }

    final currentText = amountController.text.trim();
    final total = subItemsTotal;

    if (currentText.isEmpty) {
      amountController.text = total.toStringAsFixed(2);
      return;
    }

    final parsed = double.tryParse(currentText.replaceAll(',', '.'));
    if (parsed == null || parsed < total) {
      amountController.text = total.toStringAsFixed(2);
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
    if ((attachmentPath ?? '').trim() != initialAttachmentPath) {
      return true;
    }
    if ((pendingAttachmentSourcePath ?? '').trim().isNotEmpty) {
      return true;
    }
    if (secondaryAttachmentPaths.length !=
        initialSecondaryAttachmentPaths.length) {
      return true;
    }
    if (secondaryAttachmentNames.length !=
        initialSecondaryAttachmentNames.length) {
      return true;
    }
    for (var i = 0; i < secondaryAttachmentPaths.length; i++) {
      if (secondaryAttachmentPaths[i] != initialSecondaryAttachmentPaths[i]) {
        return true;
      }
      if (secondaryAttachmentNames[i] != initialSecondaryAttachmentNames[i]) {
        return true;
      }
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

  ExpenseItem? tryBuildDraft() {
    final parsedAmount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );
    if (parsedAmount == null || parsedAmount <= 0) {
      return null;
    }

    return ExpenseItem(
      id: item?.id,
      accountType: selectedAccount,
      description: descriptionController.text.trim(),
      vendor: vendorController.text.trim(),
      category: selectedCategory,
      amount: parsedAmount,
      date: selectedDate,
      isDeductible: isDeductible,
      notes: notesController.text.trim(),
      attachmentPath: attachmentPath,
      secondaryAttachmentPaths: secondaryAttachmentPaths,
      secondaryAttachmentNames: secondaryAttachmentNames,
      subItems: subItems,
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    vendorController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

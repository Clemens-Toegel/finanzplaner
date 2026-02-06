import 'package:flutter_test/flutter_test.dart';
import 'package:finanzplaner/models/expense_account_type.dart';
import 'package:finanzplaner/models/expense_sub_item.dart';
import 'package:finanzplaner/state/add_edit_purchase_controller.dart';

void main() {
  group('AddEditPurchaseController', () {
    test('initializes with defaults and computes derived values', () {
      final controller = AddEditPurchaseController(
        selectedAccount: ExpenseAccountType.business,
        categories: const ['Office', 'Travel'],
      );

      expect(controller.selectedCategory, 'Office');
      expect(controller.hasMinimumDetails, isFalse);
      expect(controller.canAddSubItem, isTrue);
      controller.dispose();
    });

    test('applySubItemsTotalToAmount updates amount', () {
      final controller = AddEditPurchaseController(
        selectedAccount: ExpenseAccountType.business,
        categories: const ['Office'],
      );
      controller.setSubItems(const [
        ExpenseSubItem(description: 'A', amount: 10),
        ExpenseSubItem(description: 'B', amount: 15),
      ]);

      controller.applySubItemsTotalToAmount();

      expect(controller.amountController.text, '25.00');
      expect(controller.subItemsTotal, 25);
      controller.dispose();
    });

    test('hasUnsavedChanges reflects form changes', () {
      final controller = AddEditPurchaseController(
        selectedAccount: ExpenseAccountType.business,
        categories: const ['Office'],
      );

      expect(controller.hasUnsavedChanges(), isFalse);
      controller.descriptionController.text = 'Laptop';
      expect(controller.hasUnsavedChanges(), isTrue);
      controller.dispose();
    });
  });
}

import 'package:freezed_annotation/freezed_annotation.dart';

import 'expense_account_type.dart';

part 'purchase_item.freezed.dart';
part 'purchase_item.g.dart';

@freezed
abstract class PurchaseItem with _$PurchaseItem {
  const factory PurchaseItem({
    int? id,
    required ExpenseAccountType accountType,
    required String description,
    required String vendor,
    required String category,
    required double amount,
    required DateTime date,
    required bool isDeductible,
    required String notes,
  }) = _PurchaseItem;

  factory PurchaseItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseItemFromJson(json);

  const PurchaseItem._();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'account': accountType.storageValue,
      'description': description,
      'vendor': vendor,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'deductible': isDeductible ? 1 : 0,
      'notes': notes,
    };
  }

  factory PurchaseItem.fromMap(Map<String, Object?> map) {
    return PurchaseItem(
      id: map['id'] as int?,
      accountType: ExpenseAccountTypeStorage.fromStorage(
        map['account'] as String? ?? 'personal',
      ),
      description: map['description'] as String? ?? '',
      vendor: map['vendor'] as String? ?? '',
      category: map['category'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      isDeductible: (map['deductible'] as int? ?? 0) == 1,
      notes: map['notes'] as String? ?? '',
    );
  }
}

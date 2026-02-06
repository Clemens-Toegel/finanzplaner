import 'expense_sub_item.dart';

class OcrBillData {
  const OcrBillData({
    required this.rawText,
    this.vendor,
    this.description,
    this.amount,
    this.date,
    this.notes,
    this.subItems = const [],
  });

  final String rawText;
  final String? vendor;
  final String? description;
  final double? amount;
  final DateTime? date;
  final String? notes;
  final List<ExpenseSubItem> subItems;
}

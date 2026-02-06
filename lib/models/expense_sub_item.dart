class ExpenseSubItem {
  const ExpenseSubItem({required this.description, required this.amount});

  final String description;
  final double amount;

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
  };

  factory ExpenseSubItem.fromJson(Map<String, dynamic> json) {
    return ExpenseSubItem(
      description: (json['description'] as String? ?? '').trim(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

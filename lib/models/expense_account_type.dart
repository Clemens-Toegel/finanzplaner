enum ExpenseAccountType { personal, business }

extension ExpenseAccountTypeStorage on ExpenseAccountType {
  String get storageValue {
    switch (this) {
      case ExpenseAccountType.personal:
        return 'personal';
      case ExpenseAccountType.business:
        return 'business';
    }
  }

  static ExpenseAccountType fromStorage(String value) {
    switch (value) {
      case 'business':
        return ExpenseAccountType.business;
      case 'personal':
      default:
        return ExpenseAccountType.personal;
    }
  }
}

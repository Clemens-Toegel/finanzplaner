import 'expense_account_type.dart';

class AccountSettings {
  const AccountSettings({
    required this.accountType,
    this.displayName = '',
    this.companyRegisterNumber = '',
  });

  final ExpenseAccountType accountType;
  final String displayName;
  final String companyRegisterNumber;

  AccountSettings copyWith({
    ExpenseAccountType? accountType,
    String? displayName,
    String? companyRegisterNumber,
  }) {
    return AccountSettings(
      accountType: accountType ?? this.accountType,
      displayName: displayName ?? this.displayName,
      companyRegisterNumber:
          companyRegisterNumber ?? this.companyRegisterNumber,
    );
  }
}

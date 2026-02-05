import '../gen/app_localizations.dart';
import '../models/expense_account_type.dart';

extension AppLocalizationsExt on AppLocalizations {
  String accountLabel(ExpenseAccountType account) {
    return account == ExpenseAccountType.business
        ? accountLabelBusiness
        : accountLabelPersonal;
  }

  String accountLabelInSentence(ExpenseAccountType account) {
    return account == ExpenseAccountType.business
        ? accountLabelInSentenceBusiness
        : accountLabelInSentencePersonal;
  }

  List<String> categoriesForAccount(ExpenseAccountType account) {
    if (account == ExpenseAccountType.personal) {
      return [
        categoryPersonalGroceries,
        categoryPersonalHousehold,
        categoryPersonalHealth,
        categoryPersonalMobility,
        categoryPersonalEducation,
        categoryPersonalLeisure,
        categoryPersonalOther,
      ];
    }
    return [
      categoryBusinessOfficeSupplies,
      categoryBusinessHardware,
      categoryBusinessSoftware,
      categoryBusinessTravel,
      categoryBusinessTraining,
      categoryBusinessServices,
      categoryBusinessOther,
    ];
  }
}

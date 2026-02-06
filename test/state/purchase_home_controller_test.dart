import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:finanzplaner/gen/app_localizations.dart';
import 'package:finanzplaner/gen/app_localizations_en.dart';
import 'package:finanzplaner/models/account_settings.dart';
import 'package:finanzplaner/models/expense_account_type.dart';
import 'package:finanzplaner/models/purchase_item.dart';
import 'package:finanzplaner/services/purchase_home_service.dart';
import 'package:finanzplaner/state/purchase_home_controller.dart';

class _FakePurchaseHomeService implements PurchaseHomeService {
  final Map<ExpenseAccountType, List<PurchaseItem>> store = {
    ExpenseAccountType.business: [],
    ExpenseAccountType.personal: [],
  };

  Map<ExpenseAccountType, AccountSettings> settings = {
    ExpenseAccountType.personal: const AccountSettings(
      accountType: ExpenseAccountType.personal,
      displayName: 'Private',
    ),
    ExpenseAccountType.business: const AccountSettings(
      accountType: ExpenseAccountType.business,
      displayName: 'Business',
    ),
  };

  int _id = 1;

  @override
  Future<void> deletePurchase(int id) async {
    for (final key in store.keys) {
      store[key] = store[key]!.where((e) => e.id != id).toList();
    }
  }

  @override
  Future<void> exportPdf({
    required ExpenseAccountType account,
    required List<PurchaseItem> items,
    required AppLocalizations localizations,
    required AccountSettings? accountSettings,
  }) async {}

  @override
  Future<Map<ExpenseAccountType, AccountSettings>>
  fetchAccountSettings() async {
    return settings;
  }

  @override
  Future<List<PurchaseItem>> fetchPurchases(ExpenseAccountType account) async {
    return List<PurchaseItem>.from(store[account]!);
  }

  @override
  Future<PurchaseItem> insertPurchase(PurchaseItem item) async {
    final saved = item.copyWith(id: _id++);
    store[item.accountType] = [saved, ...store[item.accountType]!];
    return saved;
  }

  @override
  Future<void> saveAccountSettings(
    Map<ExpenseAccountType, AccountSettings> settings,
  ) async {
    this.settings = settings;
  }

  @override
  Future<PurchaseItem> updatePurchase(PurchaseItem item) async {
    final list = store[item.accountType]!;
    final index = list.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      list[index] = item;
    }
    return item;
  }
}

PurchaseItem _item({
  int? id,
  required ExpenseAccountType account,
  required DateTime date,
  double amount = 10,
}) {
  return PurchaseItem(
    id: id,
    accountType: account,
    description: 'Item',
    vendor: 'Shop',
    category: 'Cat',
    amount: amount,
    date: date,
    isDeductible: true,
    notes: '',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PurchaseHomeController', () {
    test(
      'initialize loads settings and purchases sorted desc by date',
      () async {
        final service = _FakePurchaseHomeService();
        service.store[ExpenseAccountType.business] = [
          _item(
            id: 1,
            account: ExpenseAccountType.business,
            date: DateTime(2024, 1, 1),
          ),
          _item(
            id: 2,
            account: ExpenseAccountType.business,
            date: DateTime(2024, 2, 1),
          ),
        ];

        final controller = PurchaseHomeController(service: service);
        await controller.initialize();

        expect(controller.isLoading, isFalse);
        expect(controller.items.first.id, 2);
        expect(
          controller.accountSettings[ExpenseAccountType.business]!.displayName,
          'Business',
        );
        controller.dispose();
      },
    );

    test('savePurchaseDraft inserts new item', () async {
      final service = _FakePurchaseHomeService();
      final controller = PurchaseHomeController(service: service);

      await controller.savePurchaseDraft(
        _item(account: ExpenseAccountType.business, date: DateTime(2025, 1, 1)),
      );

      expect(controller.items, hasLength(1));
      expect(controller.items.first.id, isNotNull);
      controller.dispose();
    });

    test('changeAccount reloads list for selected account', () async {
      final service = _FakePurchaseHomeService();
      service.store[ExpenseAccountType.business] = [
        _item(
          id: 1,
          account: ExpenseAccountType.business,
          date: DateTime(2024, 1, 1),
        ),
      ];
      service.store[ExpenseAccountType.personal] = [
        _item(
          id: 2,
          account: ExpenseAccountType.personal,
          date: DateTime(2024, 3, 1),
        ),
      ];

      final controller = PurchaseHomeController(service: service);
      await controller.initialize();
      await controller.changeAccount(ExpenseAccountType.personal);

      expect(controller.selectedAccount, ExpenseAccountType.personal);
      expect(controller.items.single.id, 2);
      controller.dispose();
    });

    test('exportPdf delegates without throwing', () async {
      final controller = PurchaseHomeController(
        service: _FakePurchaseHomeService(),
      );
      await controller.exportPdf(AppLocalizationsEn());
      controller.dispose();
    });

    test(
      'exportExcelForTaxConsultant returns false when there is no data',
      () async {
        final controller = PurchaseHomeController(
          service: _FakePurchaseHomeService(),
        );

        final result = await controller.exportExcelForTaxConsultant(
          AppLocalizationsEn(),
          sharePositionOrigin: const Rect.fromLTWH(1, 1, 10, 10),
        );

        expect(result, isFalse);
        controller.dispose();
      },
    );
  });
}

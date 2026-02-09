import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:pilo/app.dart';
import 'package:pilo/data/expense_repository.dart';
import 'package:pilo/models/expense_account_type.dart';
import 'package:pilo/models/expense_item.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilVisible(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    throw TestFailure('Timed out waiting for widget: $finder');
  }

  Future<bool> tapFirstVisible(WidgetTester tester, List<Finder> finders) async {
    for (final finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        return true;
      }
    }
    return false;
  }

  Future<void> seedDemoData() async {
    final dbPath = await getDatabasesPath();
    await deleteDatabase(p.join(dbPath, 'expense_tracker.db'));

    final repo = ExpenseRepository();
    final now = DateTime.now();

    await repo.insertExpense(
      ExpenseItem(
        accountType: ExpenseAccountType.business,
        description: 'Office chair mat',
        vendor: 'Office Depot',
        category: 'Office supplies',
        amount: 42.50,
        date: now.subtract(const Duration(days: 2)),
        isDeductible: true,
        notes: 'Desk setup improvement.',
      ),
    );

    await repo.insertExpense(
      ExpenseItem(
        accountType: ExpenseAccountType.personal,
        description: 'Weekly groceries',
        vendor: 'Fresh Market',
        category: 'Groceries',
        amount: 72.35,
        date: now.subtract(const Duration(days: 1)),
        isDeductible: false,
        notes: 'Family groceries for the week.',
      ),
    );
  }

  setUpAll(() async {
    await seedDemoData();
  });

  testWidgets('capture private account and settings screenshots', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpWidget(const PiloApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final accountDropdown = find.byType(DropdownButtonFormField<ExpenseAccountType>);
    await pumpUntilVisible(tester, accountDropdown);
    await tester.tap(accountDropdown.first);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    final pickedPersonal = await tapFirstVisible(tester, [
      find.text('Personal expenses'),
      find.text('Private Ausgaben'),
    ]);
    if (!pickedPersonal) {
      final center = tester.getCenter(accountDropdown.first);
      await tester.tapAt(center + const Offset(0, 56));
    }

    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('05_private_account');

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final settingsTitle = find.text('Account settings');
    if (settingsTitle.evaluate().isNotEmpty) {
      await pumpUntilVisible(tester, settingsTitle);
    } else {
      await pumpUntilVisible(tester, find.text('Kontoeinstellungen'));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await binding.takeScreenshot('06_settings_sheet');
  });
}

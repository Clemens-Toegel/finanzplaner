import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:pilo/app.dart';
import 'package:pilo/data/expense_repository.dart';
import 'package:pilo/models/expense_account_type.dart';
import 'package:pilo/models/expense_sub_item.dart';
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

  Future<void> seedDemoData() async {
    final dbPath = await getDatabasesPath();
    await deleteDatabase(p.join(dbPath, 'expense_tracker.db'));

    final repo = ExpenseRepository();
    final now = DateTime.now();

    await repo.insertExpense(
      ExpenseItem(
        accountType: ExpenseAccountType.business,
        description: 'MacBook sleeve',
        vendor: 'Office Depot',
        category: 'Hardware',
        amount: 49.90,
        date: now.subtract(const Duration(days: 2)),
        isDeductible: true,
        notes: 'Needed for client meetings and travel.',
        subItems: const [
          ExpenseSubItem(description: 'Sleeve', amount: 39.90),
          ExpenseSubItem(description: 'Shipping', amount: 10.00),
        ],
      ),
    );

    await repo.insertExpense(
      ExpenseItem(
        accountType: ExpenseAccountType.business,
        description: 'Team lunch',
        vendor: 'Bistro Momo',
        category: 'Services',
        amount: 128.40,
        date: now.subtract(const Duration(days: 5)),
        isDeductible: false,
        notes: 'Monthly team sync lunch.',
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

  testWidgets('capture store screenshots', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpWidget(const PiloApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await binding.takeScreenshot('01_dashboard');

    await tester.tap(find.text('MacBook sleeve').first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await pumpUntilVisible(tester, find.byIcon(Icons.picture_as_pdf_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('02_expense_detail');

    final backArrow = find.byIcon(Icons.arrow_back);
    final backTooltipEn = find.byTooltip('Back');
    final backTooltipDe = find.byTooltip('Zurück');
    if (backArrow.evaluate().isNotEmpty) {
      await tester.tap(backArrow.first);
    } else if (backTooltipEn.evaluate().isNotEmpty) {
      await tester.tap(backTooltipEn.first);
    } else if (backTooltipDe.evaluate().isNotEmpty) {
      await tester.tap(backTooltipDe.first);
    } else {
      await tester.binding.handlePopRoute();
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await pumpUntilVisible(tester, find.byIcon(Icons.playlist_add_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('03_add_expense_modal');

    await tester.tap(find.byIcon(Icons.playlist_add_outlined));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await pumpUntilVisible(tester, find.byType(TabBar));
    await tester.pump(const Duration(milliseconds: 400));
    await binding.takeScreenshot('04_sub_items_notes_modal');

    final saveEn = find.text('Save');
    final saveDe = find.text('Speichern');
    if (saveEn.evaluate().isNotEmpty) {
      await tester.tap(saveEn.last);
    } else if (saveDe.evaluate().isNotEmpty) {
      await tester.tap(saveDe.last);
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final cancelEn = find.text('Cancel');
    final cancelDe = find.text('Abbrechen');
    if (cancelEn.evaluate().isNotEmpty) {
      await tester.tap(cancelEn.first);
    } else if (cancelDe.evaluate().isNotEmpty) {
      await tester.tap(cancelDe.first);
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final discardButtonEn = find.text('Discard');
    final discardButtonDe = find.text('Verwerfen');
    if (discardButtonEn.evaluate().isNotEmpty) {
      await tester.tap(discardButtonEn.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } else if (discardButtonDe.evaluate().isNotEmpty) {
      await tester.tap(discardButtonDe.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
  });
}

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/account_settings.dart';
import '../models/expense_account_type.dart';
import '../models/purchase_item.dart';

class PurchaseRepository {
  static final PurchaseRepository _instance = PurchaseRepository._internal();

  PurchaseRepository._internal();

  factory PurchaseRepository() => _instance;

  Database? _database;

  Future<Database> _openDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final filePath = path.join(dbPath, 'purchase_tracker.db');

    _database = await openDatabase(
      filePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE purchases(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account TEXT NOT NULL,
            description TEXT NOT NULL,
            vendor TEXT,
            category TEXT,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            deductible INTEGER NOT NULL,
            notes TEXT,
            attachment_path TEXT,
            sub_items TEXT NOT NULL DEFAULT '[]'
          )
          ''');
        await db.execute('''
          CREATE TABLE account_settings(
            account TEXT PRIMARY KEY,
            display_name TEXT NOT NULL DEFAULT '',
            company_register_number TEXT NOT NULL DEFAULT ''
          )
          ''');
        await db.insert('account_settings', {
          'account': ExpenseAccountType.personal.storageValue,
          'display_name': '',
          'company_register_number': '',
        });
        await db.insert('account_settings', {
          'account': ExpenseAccountType.business.storageValue,
          'display_name': '',
          'company_register_number': '',
        });
      },
    );

    return _database!;
  }

  Future<List<PurchaseItem>> fetchPurchases(ExpenseAccountType account) async {
    final db = await _openDatabase();
    final maps = await db.query(
      'purchases',
      where: 'account = ?',
      whereArgs: [account.storageValue],
      orderBy: 'date DESC, id DESC',
    );
    return maps.map(PurchaseItem.fromMap).toList();
  }

  Future<PurchaseItem> insertPurchase(PurchaseItem item) async {
    final db = await _openDatabase();
    final id = await db.insert('purchases', item.toMap());
    return item.copyWith(id: id);
  }

  Future<PurchaseItem> updatePurchase(PurchaseItem item) async {
    if (item.id == null) {
      return item;
    }
    final db = await _openDatabase();
    await db.update(
      'purchases',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    return item;
  }

  Future<void> deletePurchase(int id) async {
    final db = await _openDatabase();
    await db.delete('purchases', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<ExpenseAccountType, AccountSettings>>
  fetchAccountSettings() async {
    final db = await _openDatabase();
    final rows = await db.query('account_settings');

    final settings = <ExpenseAccountType, AccountSettings>{
      ExpenseAccountType.personal: const AccountSettings(
        accountType: ExpenseAccountType.personal,
      ),
      ExpenseAccountType.business: const AccountSettings(
        accountType: ExpenseAccountType.business,
      ),
    };

    for (final row in rows) {
      final account = ExpenseAccountTypeStorage.fromStorage(
        row['account'] as String? ?? 'personal',
      );
      settings[account] = AccountSettings(
        accountType: account,
        displayName: (row['display_name'] as String? ?? '').trim(),
        companyRegisterNumber: (row['company_register_number'] as String? ?? '')
            .trim(),
      );
    }

    return settings;
  }

  Future<void> saveAccountSettings(AccountSettings settings) async {
    final db = await _openDatabase();
    await db.insert('account_settings', {
      'account': settings.accountType.storageValue,
      'display_name': settings.displayName.trim(),
      'company_register_number': settings.companyRegisterNumber.trim(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

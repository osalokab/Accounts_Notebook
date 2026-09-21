import 'package:sqflite/sqflite.dart';
import '../models/currency.dart';
import '../services/database_service.dart';

class CurrencyRepository {
  final DatabaseService _dbService;

  CurrencyRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Currency>> getAllCurrencies() async {
    final db = await _dbService.database;
    final maps = await db.query('currencies', orderBy: 'is_default DESC, id ASC');
    return maps.map((m) => Currency.fromMap(m)).toList();
  }

  Future<Currency?> getCurrencyById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('currencies', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Currency.fromMap(maps.first);
    }
    return null;
  }

  Future<Currency?> getDefaultCurrency() async {
    final db = await _dbService.database;
    final maps = await db.query('currencies', where: 'is_default = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return Currency.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCurrency(Currency currency) async {
    final db = await _dbService.database;
    if (currency.isDefault) {
      // Unset previous defaults
      await db.update('currencies', {'is_default': 0});
    }
    return await db.insert('currencies', currency.toMap());
  }

  Future<int> updateCurrency(Currency currency) async {
    final db = await _dbService.database;
    if (currency.isDefault) {
      await db.update('currencies', {'is_default': 0});
    }
    return await db.update(
      'currencies',
      currency.toMap(),
      where: 'id = ?',
      whereArgs: [currency.id],
    );
  }

  Future<bool> deleteCurrency(int id) async {
    final db = await _dbService.database;
    // Check if currency is used in transactions or accounts
    final transCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM transactions WHERE currency_id = ?',
      [id],
    )) ?? 0;

    final accountsCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM accounts WHERE currency_id = ?',
      [id],
    )) ?? 0;

    if (transCount > 0 || accountsCount > 0) {
      return false; // Cannot delete currency with existing references
    }

    await db.delete('currencies', where: 'id = ?', whereArgs: [id]);
    return true;
  }

  Future<void> setDefaultCurrency(int id) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.update('currencies', {'is_default': 0});
      await txn.update('currencies', {'is_default': 1}, where: 'id = ?', whereArgs: [id]);
    });
  }
}

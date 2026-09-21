import '../models/account.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';

class AccountRepository {
  final DatabaseService _dbService;

  AccountRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<List<Account>> getAllAccounts({int? categoryId, String? searchQuery}) async {
    final db = await _dbService.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (categoryId != null && categoryId > 0) {
      whereClause = 'category_id = ?';
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = '%${searchQuery.trim()}%';
      if (whereClause.isNotEmpty) {
        whereClause += ' AND (name LIKE ? OR phone LIKE ?)';
      } else {
        whereClause = '(name LIKE ? OR phone LIKE ?)';
      }
      whereArgs.addAll([query, query]);
    }

    final maps = await db.query(
      'accounts',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'updated_at DESC, id DESC',
    );

    return maps.map((m) => Account.fromMap(m)).toList();
  }

  Future<Account?> getAccountById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<Account?> getAccountByName(String name) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'accounts',
      where: 'LOWER(TRIM(name)) = LOWER(TRIM(?))',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertAccount(Account account) async {
    final db = await _dbService.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await _dbService.database;
    final updated = account.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'accounts',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<void> deleteAccount(int id) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'account_id = ?', whereArgs: [id]);
      await txn.delete('recurring_transactions', where: 'account_id = ?', whereArgs: [id]);
      await txn.delete('accounts', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Recalculates the account balance strictly from transactions + initialBalance
  Future<double> recalculateBalance(int accountId) async {
    final db = await _dbService.database;
    return await db.transaction<double>((txn) async {
      final accountMap = await txn.query('accounts', where: 'id = ?', whereArgs: [accountId]);
      if (accountMap.isEmpty) return 0.0;
      final account = Account.fromMap(accountMap.first);

      final debitResult = await txn.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE account_id = ? AND type = 'debit'",
        [accountId],
      );
      final creditResult = await txn.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE account_id = ? AND type = 'credit'",
        [accountId],
      );

      final debitTotal = (debitResult.first['total'] as num?)?.toDouble() ?? 0.0;
      final creditTotal = (creditResult.first['total'] as num?)?.toDouble() ?? 0.0;

      final netBalance = AppFormatters.roundMoney(account.initialBalance + debitTotal - creditTotal);

      await txn.update(
        'accounts',
        {
          'current_balance': netBalance,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [accountId],
      );

      return netBalance;
    });
  }

  /// Close / Settle account: Summarizes all current transactions into a single opening balance transaction or zeros it
  Future<void> settleAccount(int accountId, {required bool keepBalance}) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      final accountMap = await txn.query('accounts', where: 'id = ?', whereArgs: [accountId]);
      if (accountMap.isEmpty) return;
      final account = Account.fromMap(accountMap.first);
      final currentBal = account.currentBalance;

      // Delete past transactions
      await txn.delete('transactions', where: 'account_id = ?', whereArgs: [accountId]);

      if (keepBalance && currentBal != 0) {
        // Create settlement consolidation record
        final type = currentBal > 0 ? 'debit' : 'credit';
        await txn.insert('transactions', {
          'account_id': accountId,
          'amount': currentBal.abs(),
          'type': type,
          'currency_id': account.currencyId ?? 1,
          'date': DateTime.now().toIso8601String(),
          'description': 'تسوية وإغلاق رصيد مرحل',
          'created_at': DateTime.now().toIso8601String(),
        });
        await txn.update(
          'accounts',
          {
            'initial_balance': 0.0,
            'current_balance': currentBal,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [accountId],
        );
      } else {
        // Zero out completely
        await txn.update(
          'accounts',
          {
            'initial_balance': 0.0,
            'current_balance': 0.0,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [accountId],
        );
      }
    });
  }
}

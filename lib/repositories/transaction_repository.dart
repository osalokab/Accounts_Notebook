import '../models/transaction.dart';
import '../services/database_service.dart';
import 'account_repository.dart';

class TransactionRepository {
  final DatabaseService _dbService;
  final AccountRepository _accountRepo;

  TransactionRepository({
    DatabaseService? dbService,
    AccountRepository? accountRepo,
  })  : _dbService = dbService ?? DatabaseService.instance,
        _accountRepo = accountRepo ?? AccountRepository(dbService: dbService);

  Future<List<TransactionModel>> getTransactionsForAccount(
    int accountId, {
    bool ascending = true,
  }) async {
    final db = await _dbService.database;
    final order = ascending ? 'ASC' : 'DESC';
    final maps = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date $order, id $order',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? currencyId,
    String? type,
    String? searchQuery,
  }) async {
    final db = await _dbService.database;
    List<String> conditions = [];
    List<dynamic> args = [];

    if (startDate != null) {
      conditions.add('date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('date <= ?');
      args.add(endDate.toIso8601String());
    }

    if (currencyId != null && currencyId > 0) {
      conditions.add('currency_id = ?');
      args.add(currencyId);
    }

    if (type != null && type.isNotEmpty) {
      conditions.add('type = ?');
      args.add(type);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      conditions.add('(description LIKE ? OR amount LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      args.addAll([q, q]);
    }

    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date DESC, id DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await _dbService.database;
    final maps = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return TransactionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await _dbService.database;
    int newId = 0;
    await db.transaction((txn) async {
      newId = await txn.insert('transactions', transaction.toMap());
    });
    // Strict requirement: Recalculate account balance immediately
    await _accountRepo.recalculateBalance(transaction.accountId);
    return newId;
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await _dbService.database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    });
    // Strict requirement: Recalculate account balance after edit
    await _accountRepo.recalculateBalance(transaction.accountId);
    return count;
  }

  Future<void> deleteTransaction(int id) async {
    final trans = await getTransactionById(id);
    if (trans == null) return;

    final db = await _dbService.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

    // Strict requirement: Recalculate account balance after deletion
    await _accountRepo.recalculateBalance(trans.accountId);
  }

  /// Calculates running balance for a list of transactions of an account
  /// starting with the account's initialBalance
  List<Map<String, dynamic>> calculateStatement(
    double initialBalance,
    List<TransactionModel> transactionsAscending,
  ) {
    List<Map<String, dynamic>> statement = [];
    double current = initialBalance;

    for (var tx in transactionsAscending) {
      if (tx.type == TransactionModel.typeDebit) {
        current += tx.amount;
      } else {
        current -= tx.amount;
      }
      current = (current * 100).roundToDouble() / 100.0;
      statement.add({
        'transaction': tx,
        'running_balance': current,
      });
    }

    return statement;
  }
}

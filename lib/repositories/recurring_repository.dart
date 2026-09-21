import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import 'transaction_repository.dart';

class RecurringRepository {
  final DatabaseService _dbService;
  final TransactionRepository _transRepo;

  RecurringRepository({
    DatabaseService? dbService,
    TransactionRepository? transRepo,
  })  : _dbService = dbService ?? DatabaseService.instance,
        _transRepo = transRepo ?? TransactionRepository(dbService: dbService);

  Future<List<RecurringTransaction>> getAllRecurring() async {
    final db = await _dbService.database;
    final maps = await db.query('recurring_transactions', orderBy: 'id DESC');
    return maps.map((m) => RecurringTransaction.fromMap(m)).toList();
  }

  Future<int> insertRecurring(RecurringTransaction item) async {
    final db = await _dbService.database;
    return await db.insert('recurring_transactions', item.toMap());
  }

  Future<int> updateRecurring(RecurringTransaction item) async {
    final db = await _dbService.database;
    return await db.update(
      'recurring_transactions',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteRecurring(int id) async {
    final db = await _dbService.database;
    await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Processes active recurring items that are due and creates actual transactions
  Future<int> processDueRecurringTransactions() async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final maps = await db.query(
      'recurring_transactions',
      where: 'is_active = 1 AND next_execution_date <= ?',
      whereArgs: [now.toIso8601String()],
    );

    int executedCount = 0;

    for (var m in maps) {
      final item = RecurringTransaction.fromMap(m);

      // Create transaction
      final tx = TransactionModel(
        accountId: item.accountId,
        amount: item.amount,
        type: item.type,
        currencyId: item.currencyId,
        date: now,
        description: item.description != null
            ? '${item.description} (تكرار آلي)'
            : 'عملية متكررة آلية',
      );

      await _transRepo.insertTransaction(tx);
      executedCount++;

      // Compute next execution date
      DateTime nextDate = item.nextExecutionDate;
      if (item.frequency == RecurringTransaction.freqDaily) {
        nextDate = nextDate.add(const Duration(days: 1));
      } else if (item.frequency == RecurringTransaction.freqWeekly) {
        nextDate = nextDate.add(const Duration(days: 7));
      } else if (item.frequency == RecurringTransaction.freqMonthly) {
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
      }

      await updateRecurring(item.copyWith(nextExecutionDate: nextDate));
    }

    return executedCount;
  }
}

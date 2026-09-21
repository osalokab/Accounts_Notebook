import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../utils/formatters.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  List<TransactionModel> _accountTransactions = [];
  List<Map<String, dynamic>> _statementWithRunningBalance = [];
  List<TransactionModel> _allTransactions = [];
  bool _isLoading = false;

  TransactionProvider({TransactionRepository? repository})
      : _repository = repository ?? TransactionRepository();

  List<TransactionModel> get accountTransactions => _accountTransactions;
  List<Map<String, dynamic>> get statementWithRunningBalance => _statementWithRunningBalance;
  List<TransactionModel> get allTransactions => _allTransactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactionsForAccount(int accountId, double initialBalance) async {
    _isLoading = true;
    notifyListeners();

    // Fetch ascending for correct mathematical running balance
    final ascList = await _repository.getTransactionsForAccount(accountId, ascending: true);
    _statementWithRunningBalance = _repository.calculateStatement(initialBalance, ascList);

    // Save descending list for UI timeline display
    _accountTransactions = ascList.reversed.toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? currencyId,
    String? type,
    String? searchQuery,
  }) async {
    _isLoading = true;
    notifyListeners();

    _allTransactions = await _repository.getAllTransactions(
      startDate: startDate,
      endDate: endDate,
      currencyId: currencyId,
      type: type,
      searchQuery: searchQuery,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<int> addTransaction(TransactionModel transaction) async {
    final id = await _repository.insertTransaction(transaction);
    return id;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
  }

  // Report calculations
  double get totalDebit {
    double sum = 0.0;
    for (var tx in _allTransactions) {
      if (tx.isDebit) sum += tx.amount;
    }
    return AppFormatters.roundMoney(sum);
  }

  double get totalCredit {
    double sum = 0.0;
    for (var tx in _allTransactions) {
      if (tx.isCredit) sum += tx.amount;
    }
    return AppFormatters.roundMoney(sum);
  }

  double get netBalance => AppFormatters.roundMoney(totalDebit - totalCredit);

  Map<String, Map<String, double>> getMonthlySummary() {
    // Map: '2026-09' -> {'debit': 0, 'credit': 0, 'net': 0}
    Map<String, Map<String, double>> summary = {};

    for (var tx in _allTransactions) {
      final key = AppFormatters.formatMonthKey(tx.date);
      if (!summary.containsKey(key)) {
        summary[key] = {'debit': 0.0, 'credit': 0.0, 'net': 0.0};
      }
      if (tx.isDebit) {
        summary[key]!['debit'] = AppFormatters.roundMoney(summary[key]!['debit']! + tx.amount);
      } else {
        summary[key]!['credit'] = AppFormatters.roundMoney(summary[key]!['credit']! + tx.amount);
      }
      summary[key]!['net'] = AppFormatters.roundMoney(summary[key]!['debit']! - summary[key]!['credit']!);
    }

    return summary;
  }
}

import 'package:flutter/foundation.dart';
import '../models/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class RecurringProvider extends ChangeNotifier {
  final RecurringRepository _repository;

  List<RecurringTransaction> _items = [];
  bool _isLoading = false;

  RecurringProvider({RecurringRepository? repository})
      : _repository = repository ?? RecurringRepository();

  List<RecurringTransaction> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadRecurring() async {
    _isLoading = true;
    notifyListeners();

    _items = await _repository.getAllRecurring();

    _isLoading = false;
    notifyListeners();
  }

  Future<int> addRecurring(RecurringTransaction item) async {
    final id = await _repository.insertRecurring(item);
    await loadRecurring();
    return id;
  }

  Future<void> updateRecurring(RecurringTransaction item) async {
    await _repository.updateRecurring(item);
    await loadRecurring();
  }

  Future<void> deleteRecurring(int id) async {
    await _repository.deleteRecurring(id);
    await loadRecurring();
  }

  Future<int> checkAndExecuteDue() async {
    final count = await _repository.processDueRecurringTransactions();
    if (count > 0) {
      await loadRecurring();
    }
    return count;
  }
}

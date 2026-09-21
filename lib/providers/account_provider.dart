import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';

enum AccountSortField { name, date, balance }
enum SortOrder { ascending, descending }

class AccountProvider extends ChangeNotifier {
  final AccountRepository _repository;

  List<Account> _accounts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int? _filterCategoryId;
  int? _filterCurrencyId;

  AccountSortField _sortField = AccountSortField.name;
  SortOrder _sortOrder = SortOrder.ascending;

  AccountProvider({AccountRepository? repository})
      : _repository = repository ?? AccountRepository();

  List<Account> get accounts => _getFilteredAndSortedAccounts();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int? get filterCategoryId => _filterCategoryId;
  int? get filterCurrencyId => _filterCurrencyId;
  AccountSortField get sortField => _sortField;
  SortOrder get sortOrder => _sortOrder;

  // Bottom bar totals:
  // "عليك" (What we owe - sum of negative balances where account has Credit / له)
  // "لك" (What is owed to us - sum of positive balances where account has Debit / عليه)
  double get totalReceivable {
    double sum = 0.0;
    for (var acc in _getFilteredAccountsOnly()) {
      if (acc.currentBalance > 0) {
        sum += acc.currentBalance;
      }
    }
    return (sum * 100).roundToDouble() / 100.0;
  }

  double get totalPayable {
    double sum = 0.0;
    for (var acc in _getFilteredAccountsOnly()) {
      if (acc.currentBalance < 0) {
        sum += acc.currentBalance.abs();
      }
    }
    return (sum * 100).roundToDouble() / 100.0;
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    _accounts = await _repository.getAllAccounts();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterCategory(int? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  void setFilterCurrency(int? currencyId) {
    _filterCurrencyId = currencyId;
    notifyListeners();
  }

  void setSorting(AccountSortField field, SortOrder order) {
    _sortField = field;
    _sortOrder = order;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sortOrder = _sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;
    notifyListeners();
  }

  List<Account> _getFilteredAccountsOnly() {
    return _accounts.where((acc) {
      if (_filterCategoryId != null && _filterCategoryId! > 0) {
        if (acc.categoryId != _filterCategoryId) return false;
      }
      if (_filterCurrencyId != null && _filterCurrencyId! > 0) {
        if (acc.currencyId != _filterCurrencyId) return false;
      }
      return true;
    }).toList();
  }

  List<Account> _getFilteredAndSortedAccounts() {
    List<Account> list = _getFilteredAccountsOnly();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((acc) {
        final nameMatches = acc.name.toLowerCase().contains(q);
        final phoneMatches = acc.phone?.toLowerCase().contains(q) ?? false;
        final notesMatches = acc.notes?.toLowerCase().contains(q) ?? false;
        return nameMatches || phoneMatches || notesMatches;
      }).toList();
    }

    list.sort((a, b) {
      int cmp = 0;
      switch (_sortField) {
        case AccountSortField.name:
          cmp = a.name.compareTo(b.name);
          break;
        case AccountSortField.date:
          cmp = a.updatedAt.compareTo(b.updatedAt);
          break;
        case AccountSortField.balance:
          cmp = a.currentBalance.compareTo(b.currentBalance);
          break;
      }
      return _sortOrder == SortOrder.ascending ? cmp : -cmp;
    });

    return list;
  }

  Future<Account> getOrCreateAccount(
    String name, {
    int? categoryId,
    int? currencyId,
    String? phone,
  }) async {
    final existing = await _repository.getAccountByName(name);
    if (existing != null) {
      return existing;
    }

    final newAccount = Account(
      name: name.trim(),
      categoryId: categoryId,
      currencyId: currencyId,
      phone: phone,
      initialBalance: 0.0,
      currentBalance: 0.0,
    );
    final id = await _repository.insertAccount(newAccount);
    await loadAccounts();
    return newAccount.copyWith(id: id);
  }

  Future<int> addAccount(Account account) async {
    final id = await _repository.insertAccount(account);
    await loadAccounts();
    return id;
  }

  Future<void> updateAccount(Account account) async {
    await _repository.updateAccount(account);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    await _repository.deleteAccount(id);
    await loadAccounts();
  }

  Future<void> settleAccount(int id, {required bool keepBalance}) async {
    await _repository.settleAccount(id, keepBalance: keepBalance);
    await loadAccounts();
  }

  Future<Account?> getAccountById(int id) async {
    return await _repository.getAccountById(id);
  }
}

import 'package:flutter/foundation.dart';
import '../models/currency.dart';
import '../repositories/currency_repository.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyRepository _repository;

  List<Currency> _currencies = [];
  Currency? _selectedCurrency;
  bool _isLoading = false;

  CurrencyProvider({CurrencyRepository? repository})
      : _repository = repository ?? CurrencyRepository();

  List<Currency> get currencies => _currencies;
  Currency? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;

  Future<void> loadCurrencies() async {
    _isLoading = true;
    notifyListeners();

    _currencies = await _repository.getAllCurrencies();
    if (_currencies.isNotEmpty) {
      if (_selectedCurrency == null || !_currencies.any((c) => c.id == _selectedCurrency!.id)) {
        _selectedCurrency = _currencies.firstWhere(
          (c) => c.isDefault,
          orElse: () => _currencies.first,
        );
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCurrency(Currency currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  Future<void> addCurrency(String name, String symbol, {bool isDefault = false}) async {
    final currency = Currency(name: name, symbol: symbol, isDefault: isDefault);
    await _repository.insertCurrency(currency);
    await loadCurrencies();
  }

  Future<void> updateCurrency(Currency currency) async {
    await _repository.updateCurrency(currency);
    await loadCurrencies();
  }

  Future<bool> deleteCurrency(int id) async {
    final success = await _repository.deleteCurrency(id);
    if (success) {
      await loadCurrencies();
    }
    return success;
  }

  Future<void> setDefaultCurrency(int id) async {
    await _repository.setDefaultCurrency(id);
    await loadCurrencies();
  }
}

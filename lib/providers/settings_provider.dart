import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../repositories/settings_repository.dart';
import '../utils/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  AppSettings _settings = AppSettings();
  bool _isUnlocked = false;
  bool _isLoading = false;

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  AppSettings get settings => _settings;
  bool get isUnlocked => _isUnlocked;
  bool get isLoading => _isLoading;

  bool get isAppLocked => _settings.isPasswordEnabled && !_isUnlocked;

  ThemeMode get themeMode {
    switch (_settings.themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Locale get locale => Locale(_settings.languageCode);
  bool get isArabic => _settings.languageCode == 'ar';

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _repository.getSettings();
    AppStrings.setLocale(_settings.languageCode);

    // If password is not enabled, default to unlocked
    if (!_settings.isPasswordEnabled) {
      _isUnlocked = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setLanguageCode(String langCode) async {
    _settings = _settings.copyWith(languageCode: langCode);
    AppStrings.setLocale(langCode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<bool> unlockWithPin(String pin) async {
    final valid = await _repository.verifyPin(pin);
    if (valid) {
      _isUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockApp() {
    if (_settings.isPasswordEnabled) {
      _isUnlocked = false;
      notifyListeners();
    }
  }

  Future<void> setPin(String newPin) async {
    final hash = SettingsRepository.hashPin(newPin);
    _settings = _settings.copyWith(
      isPasswordEnabled: true,
      passwordHash: hash,
    );
    await _repository.saveSettings(_settings);
    _isUnlocked = true;
    notifyListeners();
  }

  Future<void> disablePin() async {
    _settings = _settings.copyWith(
      isPasswordEnabled: false,
      passwordHash: null,
    );
    await _repository.saveSettings(_settings);
    _isUnlocked = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings updated) async {
    _settings = updated;
    AppStrings.setLocale(updated.languageCode);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }
}

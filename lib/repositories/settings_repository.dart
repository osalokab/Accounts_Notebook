import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/app_settings.dart';
import '../services/database_service.dart';

class SettingsRepository {
  final DatabaseService _dbService;

  SettingsRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<AppSettings> getSettings() async {
    final db = await _dbService.database;
    final maps = await db.query('settings', where: 'id = 1');
    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    }
    // Return default settings
    return AppSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await _dbService.database;
    await db.insert(
      'settings',
      {'id': 1, ...settings.toMap()},
      conflictAlgorithm: null, // replace handled below
    ).catchError((_) async {
      await db.update('settings', settings.toMap(), where: 'id = 1');
      return 1;
    });
    // Ensure update if exists
    await db.update('settings', settings.toMap(), where: 'id = 1');
  }

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<bool> verifyPin(String enteredPin) async {
    final settings = await getSettings();
    if (!settings.isPasswordEnabled || settings.passwordHash == null) {
      return true; // Not enabled
    }
    final enteredHash = hashPin(enteredPin);
    return enteredHash == settings.passwordHash;
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms or unit testing
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (kIsWeb) {
      dbPath = 'accounts_notebook.db';
    } else {
      final docsDirectory = await getApplicationDocumentsDirectory();
      dbPath = join(docsDirectory.path, 'accounts_notebook.db');
    }

    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE accounts ADD COLUMN icon_code TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE settings ADD COLUMN theme_mode TEXT DEFAULT "light"');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE settings ADD COLUMN language_code TEXT DEFAULT "ar"');
      } catch (_) {}
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Currencies Table
    await db.execute('''
      CREATE TABLE currencies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'general',
        created_at TEXT NOT NULL
      )
    ''');

    // 3. Accounts Table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER,
        currency_id INTEGER,
        phone TEXT,
        notes TEXT,
        icon_code TEXT,
        initial_balance REAL NOT NULL DEFAULT 0.0,
        current_balance REAL NOT NULL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
        FOREIGN KEY (currency_id) REFERENCES currencies (id) ON DELETE SET NULL
      )
    ''');

    // 4. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL, -- 'debit' or 'credit'
        currency_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        image_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (currency_id) REFERENCES currencies (id) ON DELETE RESTRICT
      )
    ''');

    // 5. Recurring Transactions Table
    await db.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        currency_id INTEGER NOT NULL,
        description TEXT,
        frequency TEXT NOT NULL, -- 'daily', 'weekly', 'monthly'
        start_date TEXT NOT NULL,
        next_execution_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (currency_id) REFERENCES currencies (id) ON DELETE RESTRICT
      )
    ''');

    // 6. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        is_password_enabled INTEGER NOT NULL DEFAULT 0,
        password_hash TEXT,
        default_currency_id INTEGER,
        auto_backup_daily INTEGER NOT NULL DEFAULT 1,
        auto_backup_drive INTEGER NOT NULL DEFAULT 0,
        user_name TEXT,
        company_name TEXT,
        phone TEXT,
        address TEXT,
        email TEXT,
        logo_path TEXT,
        print_show_logo INTEGER NOT NULL DEFAULT 1,
        print_show_company_info INTEGER NOT NULL DEFAULT 1,
        print_show_notes INTEGER NOT NULL DEFAULT 1,
        theme_mode TEXT DEFAULT 'light',
        language_code TEXT DEFAULT 'ar'
      )
    ''');

    // 7. Notifications Table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        date TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        type TEXT NOT NULL DEFAULT 'system'
      )
    ''');

    // 8. Insert Default Initial Seed Data
    final now = DateTime.now().toIso8601String();

    // Default Currencies (محلي، دولار، سعودي)
    await db.insert('currencies', {
      'id': 1,
      'name': 'محلي',
      'symbol': 'محلي',
      'is_default': 1,
      'created_at': now,
    });
    await db.insert('currencies', {
      'id': 2,
      'name': 'دولار',
      'symbol': '\$',
      'is_default': 0,
      'created_at': now,
    });
    await db.insert('currencies', {
      'id': 3,
      'name': 'سعودي',
      'symbol': 'ر.س',
      'is_default': 0,
      'created_at': now,
    });

    // Default Categories (عام، عملاء، موردين)
    await db.insert('categories', {
      'id': 1,
      'name': 'عام',
      'type': 'general',
      'created_at': now,
    });
    await db.insert('categories', {
      'id': 2,
      'name': 'عملاء',
      'type': 'customer',
      'created_at': now,
    });
    await db.insert('categories', {
      'id': 3,
      'name': 'موردين',
      'type': 'supplier',
      'created_at': now,
    });

    // Default Settings Row
    await db.insert('settings', {
      'id': 1,
      'is_password_enabled': 0,
      'default_currency_id': 1,
      'auto_backup_daily': 1,
      'auto_backup_drive': 0,
      'print_show_logo': 1,
      'print_show_company_info': 1,
      'print_show_notes': 1,
    });

    // Welcome Notification
    await db.insert('notifications', {
      'title': 'مرحباً بك في دفتر الحسابات',
      'message': 'تم تجهيز التطبيق بنجاح. اضغط على علامة (+) لإضافة أول عملية مالية.',
      'date': now,
      'is_read': 0,
      'type': 'system',
    });
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Clear all data for restore
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('recurring_transactions');
    await db.delete('accounts');
    await db.delete('notifications');
  }
}

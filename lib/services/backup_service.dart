import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';

class BackupResult {
  final bool success;
  final String message;
  final String? filePath;

  BackupResult({required this.success, required this.message, this.filePath});
}

class BackupService {
  static const String appSignature = 'accounts_notebook_backup_v1';

  /// Exports all data into a validated JSON file and offers to share or save it
  static Future<BackupResult> exportBackup({bool shareAfterExport = true}) async {
    try {
      final db = await DatabaseService.instance.database;

      final accounts = await db.query('accounts');
      final transactions = await db.query('transactions');
      final currencies = await db.query('currencies');
      final categories = await db.query('categories');
      final settings = await db.query('settings');
      final recurring = await db.query('recurring_transactions');

      final payload = {
        'signature': appSignature,
        'version': 1,
        'created_at': DateTime.now().toIso8601String(),
        'data': {
          'accounts': accounts,
          'transactions': transactions,
          'currencies': currencies,
          'categories': categories,
          'settings': settings,
          'recurring_transactions': recurring,
        }
      };

      final jsonString = jsonEncode(payload);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'accounts_notebook_backup_$timestamp.json';

      final dir = await getApplicationDocumentsDirectory();
      final backupFile = File('${dir.path}/$filename');
      await backupFile.writeAsString(jsonString, flush: true);

      if (shareAfterExport) {
        await Share.shareXFiles(
          [XFile(backupFile.path, mimeType: 'application/json')],
          subject: 'نسخة احتياطية - دفتر الحسابات',
        );
      }

      return BackupResult(
        success: true,
        message: 'تم إنشاء وحفظ النسخة الاحتياطية بنجاح',
        filePath: backupFile.path,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'فشل تصدير النسخة الاحتياطية: ${e.toString()}',
      );
    }
  }

  /// Picks a file, validates signature and tables, then restores safely inside a single transaction
  static Future<BackupResult> importAndRestoreBackup() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'db'],
      );

      if (files.isEmpty || files.first.path == null) {
        return BackupResult(success: false, message: 'لم يتم اختيار أي ملف');
      }

      final file = File(files.first.path!);
      final content = await file.readAsString();

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        return BackupResult(success: false, message: 'الملف المختار ليس بصيغة نسخة احتياطية صالحة');
      }

      // Validate signature
      if (parsed['signature'] != appSignature && parsed['signature'] != 'accounts_notebook_backup') {
        return BackupResult(
          success: false,
          message: 'ملف النسخة الاحتياطية غير متوافق مع هذا التطبيق',
        );
      }

      final data = parsed['data'] as Map<String, dynamic>?;
      if (data == null) {
        return BackupResult(success: false, message: 'محتوى النسخة الاحتياطية فارغ أو تالف');
      }

      final db = await DatabaseService.instance.database;

      // Atomic restoration inside a transaction
      await db.transaction((txn) async {
        // 1. Clear existing data
        await txn.delete('transactions');
        await txn.delete('recurring_transactions');
        await txn.delete('accounts');
        await txn.delete('categories');
        await txn.delete('currencies');

        // 2. Restore Currencies
        if (data['currencies'] != null) {
          for (var item in data['currencies']) {
            await txn.insert('currencies', Map<String, dynamic>.from(item));
          }
        }

        // 3. Restore Categories
        if (data['categories'] != null) {
          for (var item in data['categories']) {
            await txn.insert('categories', Map<String, dynamic>.from(item));
          }
        }

        // 4. Restore Accounts
        if (data['accounts'] != null) {
          for (var item in data['accounts']) {
            await txn.insert('accounts', Map<String, dynamic>.from(item));
          }
        }

        // 5. Restore Transactions
        if (data['transactions'] != null) {
          for (var item in data['transactions']) {
            await txn.insert('transactions', Map<String, dynamic>.from(item));
          }
        }

        // 6. Restore Recurring
        if (data['recurring_transactions'] != null) {
          for (var item in data['recurring_transactions']) {
            await txn.insert('recurring_transactions', Map<String, dynamic>.from(item));
          }
        }

        // 7. Restore Settings if present
        if (data['settings'] != null && (data['settings'] as List).isNotEmpty) {
          await txn.delete('settings');
          for (var item in data['settings']) {
            await txn.insert('settings', Map<String, dynamic>.from(item));
          }
        }
      });

      return BackupResult(
        success: true,
        message: 'تم استرجاع قاعدة البيانات بنجاح تام',
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'حدث خطأ أثناء استرجاع البيانات: ${e.toString()}',
      );
    }
  }
}

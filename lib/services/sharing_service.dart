import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class SharingService {
  /// Shares a plain text representation of the account statement
  static Future<void> shareAccountText({
    required Account account,
    required List<Map<String, dynamic>> statement,
    String? currencySymbol,
  }) async {
    final symbol = currencySymbol ?? 'محلي';
    final buffer = StringBuffer();
    buffer.writeln('📋 كشف حساب: ${account.name}');
    if (account.phone != null && account.phone!.isNotEmpty) {
      buffer.writeln('📱 هاتف: ${account.phone}');
    }
    buffer.writeln('💰 الرصيد الحالي: ${AppFormatters.formatAmount(account.currentBalance)} $symbol');
    buffer.writeln('------------------------------');

    for (var item in statement) {
      final tx = item['transaction'] as TransactionModel;
      final running = item['running_balance'] as double;
      final typeStr = tx.isDebit ? 'عليه' : 'له';
      final desc = tx.description != null && tx.description!.isNotEmpty ? ' (${tx.description})' : '';
      buffer.writeln(
        '• ${AppFormatters.formatDisplayDate(tx.date)}: $typeStr ${AppFormatters.formatAmount(tx.amount)} $symbol$desc | الرصيد: ${AppFormatters.formatAmount(running)}',
      );
    }
    buffer.writeln('------------------------------');
    buffer.writeln('تم التصدير من تطبيق دفتر الحسابات');

    await Share.share(
      buffer.toString(),
      subject: 'كشف حساب - ${account.name}',
    );
  }

  /// Shares a PDF byte buffer by saving to a temporary file first
  static Future<void> sharePdfBytes({
    required Uint8List bytes,
    required String filename,
    String? subject,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: subject ?? filename,
    );
  }
}

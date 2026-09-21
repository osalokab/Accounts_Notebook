import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/account.dart';
import '../models/app_settings.dart';
import '../models/currency.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class PdfService {
  static pw.Font? _cachedRegularFont;
  static pw.Font? _cachedBoldFont;

  static Future<pw.Font> _loadArabicRegularFont() async {
    if (_cachedRegularFont != null) return _cachedRegularFont!;
    try {
      final fontData = await rootBundle.load('assets/fonts/arial.ttf');
      _cachedRegularFont = pw.Font.ttf(fontData);
      return _cachedRegularFont!;
    } catch (_) {
      try {
        final fontData = await rootBundle.load('assets/fonts/tahoma.ttf');
        _cachedRegularFont = pw.Font.ttf(fontData);
        return _cachedRegularFont!;
      } catch (_) {
        try {
          return await PdfGoogleFonts.cairoRegular();
        } catch (_) {
          return pw.Font.helvetica();
        }
      }
    }
  }

  static Future<pw.Font> _loadArabicBoldFont() async {
    if (_cachedBoldFont != null) return _cachedBoldFont!;
    try {
      final fontData = await rootBundle.load('assets/fonts/arialbd.ttf');
      _cachedBoldFont = pw.Font.ttf(fontData);
      return _cachedBoldFont!;
    } catch (_) {
      try {
        final fontData = await rootBundle.load('assets/fonts/tahomabd.ttf');
        _cachedBoldFont = pw.Font.ttf(fontData);
        return _cachedBoldFont!;
      } catch (_) {
        try {
          return await PdfGoogleFonts.cairoBold();
        } catch (_) {
          return pw.Font.helveticaBold();
        }
      }
    }
  }

  static Future<Uint8List> generateAccountStatementPdf({
    required Account account,
    required List<Map<String, dynamic>> statement,
    required AppSettings settings,
    Currency? currency,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await _loadArabicRegularFont();
    final boldFont = await _loadArabicBoldFont();

    final currencySymbol = currency?.symbol ?? 'محلي';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('28487D'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      settings.companyName ?? 'دفتر الحسابات',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                    ),
                    if (settings.phone != null && settings.phone!.isNotEmpty)
                      pw.Text(
                        'هاتف: ${settings.phone}',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                      ),
                  ],
                ),
                pw.Text(
                  'كشف حساب',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 20,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Account Info Box
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 1),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('اسم الحساب: ${account.name}', style: pw.TextStyle(font: boldFont, fontSize: 13)),
                    if (account.phone != null && account.phone!.isNotEmpty)
                      pw.Text('رقم الهاتف: ${account.phone}', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('العملة: $currencySymbol', style: const pw.TextStyle(fontSize: 11)),
                    pw.Text(
                      'الرصيد الحالي: ${AppFormatters.formatAmount(account.currentBalance)} $currencySymbol',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 13,
                        color: account.currentBalance > 0
                            ? PdfColor.fromHex('DC2626')
                            : account.currentBalance < 0
                                ? PdfColor.fromHex('16A34A')
                                : PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Transactions Table
          pw.TableHelper.fromTextArray(
            headers: ['التاريخ', 'البيان', 'عليه (مدين)', 'له (دائن)', 'الرصيد'],
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white, fontSize: 11),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('28487D')),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(font: arabicFont, fontSize: 10),
            data: statement.map((item) {
              final tx = item['transaction'] as TransactionModel;
              final running = item['running_balance'] as double;
              return [
                AppFormatters.formatDisplayDate(tx.date),
                tx.description ?? '-',
                tx.isDebit ? AppFormatters.formatAmount(tx.amount) : '-',
                tx.isCredit ? AppFormatters.formatAmount(tx.amount) : '-',
                AppFormatters.formatAmount(running),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'تاريخ الطباعة: ${AppFormatters.formatDate(DateTime.now())}',
                style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 9),
              ),
              pw.Text(
                'دفتر الحسابات - تطبيق محاسبي شخصي',
                style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> printStatement({
    required Account account,
    required List<Map<String, dynamic>> statement,
    required AppSettings settings,
    Currency? currency,
  }) async {
    final bytes = await generateAccountStatementPdf(
      account: account,
      statement: statement,
      settings: settings,
      currency: currency,
    );
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: 'كشف_حساب_${account.name}',
    );
  }

  static Future<Uint8List> generateReportPdf({
    required String title,
    required List<List<String>> rows,
    required List<String> headers,
    required AppSettings settings,
    String? subtitle,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await _loadArabicRegularFont();
    final boldFont = await _loadArabicBoldFont();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('28487D'),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  settings.companyName ?? 'دفتر الحسابات',
                  style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.white),
                ),
                pw.Text(
                  title,
                  style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.white),
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(subtitle, style: pw.TextStyle(font: arabicFont, fontSize: 11, color: PdfColors.grey700)),
          ],
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: headers,
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white, fontSize: 11),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('28487D')),
            cellAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(font: arabicFont, fontSize: 10),
            data: rows,
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'تاريخ الإنشاء: ${AppFormatters.formatDateTime(DateTime.now())}',
            style: pw.TextStyle(font: arabicFont, color: PdfColors.grey600, fontSize: 9),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}

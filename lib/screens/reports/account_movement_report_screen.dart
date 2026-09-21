import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:printing/printing.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class AccountMovementReportScreen extends StatefulWidget {
  const AccountMovementReportScreen({super.key});

  @override
  State<AccountMovementReportScreen> createState() => _AccountMovementReportScreenState();
}

class _AccountMovementReportScreenState extends State<AccountMovementReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final currencySymbol = context.watch<CurrencyProvider>().selectedCurrency?.symbol ?? 'محلي';
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير- حركة الحسابات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: () async {
              final rows = accounts.map((acc) {
                return [
                  acc.name,
                  acc.phone ?? '-',
                  '${AppFormatters.formatAmount(acc.initialBalance)} $currencySymbol',
                  '${AppFormatters.formatAmount(acc.currentBalance)} $currencySymbol',
                  AppFormatters.formatDisplayDate(acc.updatedAt),
                ];
              }).toList();

              final bytes = await PdfService.generateReportPdf(
                title: 'تقرير حركة وأرصدة الحسابات',
                headers: ['الحساب', 'الهاتف', 'الافتتاحي', 'الحالي', 'آخر حركة'],
                rows: rows,
                settings: settings,
              );
              await Printing.layoutPdf(onLayout: (_) => bytes, name: 'تقرير_حركة_الحسابات');
            },
          ),
        ],
      ),
      body: accounts.isEmpty
          ? const Center(child: Text('لا توجد حسابات لعرض حركتها'))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final acc = accounts[index];
                final color = acc.currentBalance > 0
                    ? AppColors.debit
                    : acc.currentBalance < 0
                        ? AppColors.credit
                        : AppColors.textPrimary;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(
                        acc.name.isNotEmpty ? acc.name[0] : '؟',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                    title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('آخر تحديث: ${AppFormatters.formatDisplayDate(acc.updatedAt)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${AppFormatters.formatAmount(acc.currentBalance)} $currencySymbol',
                          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                        ),
                        Text(
                          acc.currentBalance > 0 ? 'عليه' : acc.currentBalance < 0 ? 'له' : 'متوازن',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

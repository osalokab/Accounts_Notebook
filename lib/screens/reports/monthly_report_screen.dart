import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/currency.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:printing/printing.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int? _selectedCurrencyId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final currId = _selectedCurrencyId ?? context.read<CurrencyProvider>().selectedCurrency?.id;
    await context.read<TransactionProvider>().loadAllTransactions(currencyId: currId);
  }

  @override
  Widget build(BuildContext context) {
    final transProvider = context.watch<TransactionProvider>();
    final currencies = context.watch<CurrencyProvider>().currencies;
    final settings = context.watch<SettingsProvider>().settings;

    final curr = currencies.firstWhere(
      (c) => c.id == _selectedCurrencyId,
      orElse: () => context.watch<CurrencyProvider>().selectedCurrency ?? Currency(name: 'محلي', symbol: 'محلي'),
    );

    final monthlyData = transProvider.getMonthlySummary();
    final months = monthlyData.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير- إجمالي المبالغ شهرياً'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: () async {
              final rows = months.map((m) {
                final d = monthlyData[m]!;
                return [
                  m,
                  '${AppFormatters.formatAmount(d['debit']!)} ${curr.symbol}',
                  '${AppFormatters.formatAmount(d['credit']!)} ${curr.symbol}',
                  '${AppFormatters.formatAmount(d['net']!)} ${curr.symbol}',
                ];
              }).toList();

              final bytes = await PdfService.generateReportPdf(
                title: 'تقرير إجمالي المبالغ شهرياً',
                headers: ['الشهر', 'إجمالي عليه', 'إجمالي له', 'الصافي'],
                rows: rows,
                settings: settings,
                subtitle: 'العملة: ${curr.name}',
              );
              await Printing.layoutPdf(onLayout: (_) => bytes, name: 'تقرير_شهري');
            },
          ),
        ],
      ),
      body: transProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : months.isEmpty
              ? const Center(child: Text('لا توجد عمليات مسجلة لعرض التقرير الشهري'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final monthKey = months[index];
                    final data = monthlyData[monthKey]!;
                    final debit = data['debit'] ?? 0.0;
                    final credit = data['credit'] ?? 0.0;
                    final net = data['net'] ?? 0.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      monthKey,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (net >= 0 ? AppColors.debit : AppColors.credit).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'الصافي: ${AppFormatters.formatAmount(net)} ${curr.symbol}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: net >= 0 ? AppColors.debit : AppColors.credit,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('إجمالي (عليه)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${AppFormatters.formatAmount(debit)} ${curr.symbol}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.debit, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Container(height: 30, width: 1, color: AppColors.divider),
                                Column(
                                  children: [
                                    const Text('إجمالي (له)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${AppFormatters.formatAmount(credit)} ${curr.symbol}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.credit, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/currency.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:printing/printing.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class TotalSummaryReportScreen extends StatefulWidget {
  const TotalSummaryReportScreen({super.key});

  @override
  State<TotalSummaryReportScreen> createState() => _TotalSummaryReportScreenState();
}

class _TotalSummaryReportScreenState extends State<TotalSummaryReportScreen> {
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
    await context.read<AccountProvider>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final transProvider = context.watch<TransactionProvider>();
    final accountProvider = context.watch<AccountProvider>();
    final currencies = context.watch<CurrencyProvider>().currencies;
    final settings = context.watch<SettingsProvider>().settings;

    final curr = currencies.firstWhere(
      (c) => c.id == _selectedCurrencyId,
      orElse: () => context.watch<CurrencyProvider>().selectedCurrency ?? Currency(name: 'محلي', symbol: 'محلي'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير- إجمالي المبالغ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: () async {
              final rows = [
                ['إجمالي المبالغ المدينة (عليه)', '${AppFormatters.formatAmount(transProvider.totalDebit)} ${curr.symbol}'],
                ['إجمالي المبالغ الدائنة (له)', '${AppFormatters.formatAmount(transProvider.totalCredit)} ${curr.symbol}'],
                ['صافي الرصيد العام', '${AppFormatters.formatAmount(transProvider.netBalance)} ${curr.symbol}'],
                ['إجمالي عدد الحسابات', '${accountProvider.accounts.length}'],
                ['إجمالي عدد العمليات المسجلة', '${transProvider.allTransactions.length}'],
              ];
              final bytes = await PdfService.generateReportPdf(
                title: 'تقرير إجمالي المبالغ',
                headers: ['البيان', 'القيمة'],
                rows: rows,
                settings: settings,
                subtitle: 'العملة: ${curr.name}',
              );
              await Printing.layoutPdf(onLayout: (_) => bytes, name: 'تقرير_إجمالي_المبالغ');
            },
          ),
        ],
      ),
      body: transProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Currency Selector Dropdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('تصفية حسب العملة:', style: TextStyle(fontWeight: FontWeight.bold)),
                          DropdownButton<int>(
                            value: _selectedCurrencyId ?? curr.id,
                            items: currencies
                                .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.name} (${c.symbol})')))
                                .toList(),
                            onChanged: (val) {
                              setState(() => _selectedCurrencyId = val);
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Summary Cards Grid
                  _buildMetricCard(
                    title: 'إجمالي المبالغ المدينة (عليه)',
                    value: '${AppFormatters.formatAmount(transProvider.totalDebit)} ${curr.symbol}',
                    color: AppColors.debit,
                    icon: Icons.arrow_downward,
                  ),
                  const SizedBox(height: 10),
                  _buildMetricCard(
                    title: 'إجمالي المبالغ الدائنة (له)',
                    value: '${AppFormatters.formatAmount(transProvider.totalCredit)} ${curr.symbol}',
                    color: AppColors.credit,
                    icon: Icons.arrow_upward,
                  ),
                  const SizedBox(height: 10),
                  _buildMetricCard(
                    title: 'صافي الرصيد العام',
                    value: '${AppFormatters.formatAmount(transProvider.netBalance)} ${curr.symbol}',
                    color: transProvider.netBalance > 0
                        ? AppColors.debit
                        : transProvider.netBalance < 0
                            ? AppColors.credit
                            : AppColors.textPrimary,
                    icon: Icons.account_balance,
                  ),
                  const SizedBox(height: 14),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallStatCard(
                          label: 'عدد الحسابات',
                          val: '${accountProvider.accounts.length}',
                          icon: Icons.people_alt,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSmallStatCard(
                          label: 'عدد العمليات',
                          val: '${transProvider.allTransactions.length}',
                          icon: Icons.receipt,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String label,
    required String val,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

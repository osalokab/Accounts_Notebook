import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:printing/printing.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class TransactionDetailsReportScreen extends StatefulWidget {
  const TransactionDetailsReportScreen({super.key});

  @override
  State<TransactionDetailsReportScreen> createState() => _TransactionDetailsReportScreenState();
}

class _TransactionDetailsReportScreenState extends State<TransactionDetailsReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<AccountProvider>().loadAccounts();
    if (mounted) {
      await context.read<TransactionProvider>().loadAllTransactions(
            startDate: _startDate,
            endDate: _endDate,
            type: _selectedType,
            searchQuery: _searchCtrl.text,
          );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transProvider = context.watch<TransactionProvider>();
    final accountMap = {for (var a in context.watch<AccountProvider>().accounts) a.id!: a};
    final currencies = {for (var c in context.watch<CurrencyProvider>().currencies) c.id!: c};
    final settings = context.watch<SettingsProvider>().settings;

    final list = transProvider.allTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير- تفاصيل كل المبالغ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: () async {
              final rows = list.map((tx) {
                final accName = accountMap[tx.accountId]?.name ?? 'حساب #${tx.accountId}';
                final currSymbol = currencies[tx.currencyId]?.symbol ?? 'محلي';
                return [
                  AppFormatters.formatDisplayDate(tx.date),
                  accName,
                  tx.isDebit ? 'عليه' : 'له',
                  '${AppFormatters.formatAmount(tx.amount)} $currSymbol',
                  tx.description ?? '-',
                ];
              }).toList();

              final bytes = await PdfService.generateReportPdf(
                title: 'تقرير تفاصيل كل المبالغ',
                headers: ['التاريخ', 'الحساب', 'النوع', 'المبلغ', 'البيان'],
                rows: rows,
                settings: settings,
                subtitle: 'إجمالي العمليات المعروضة: ${list.length}',
              );
              await Printing.layoutPdf(onLayout: (_) => bytes, name: 'تقرير_تفاصيل_العمليات');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'بحث في البيان أو المبلغ...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _loadData();
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => _loadData(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Date range filter buttons
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _startDate == null ? 'من تاريخ' : AppFormatters.formatDisplayDate(_startDate!),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            final p = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              locale: const Locale('ar'),
                            );
                            if (p != null) {
                              setState(() => _startDate = p);
                              _loadData();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _endDate == null ? 'إلى تاريخ' : AppFormatters.formatDisplayDate(_endDate!),
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () async {
                            final p = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              locale: const Locale('ar'),
                            );
                            if (p != null) {
                              setState(() => _endDate = p);
                              _loadData();
                            }
                          },
                        ),
                      ),
                      if (_startDate != null || _endDate != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.filter_alt_off, color: AppColors.debit),
                          tooltip: 'مسح التواريخ',
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                            _loadData();
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Total counts badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('عدد العمليات: ${list.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  'المجموع: ${AppFormatters.formatAmount(transProvider.totalDebit)} عليه | ${AppFormatters.formatAmount(transProvider.totalCredit)} له',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : list.isEmpty
                    ? const Center(child: Text('لا توجد عمليات مطابقة للفلاتر'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final tx = list[index];
                          final acc = accountMap[tx.accountId];
                          final curr = currencies[tx.currencyId];
                          final color = tx.isDebit ? AppColors.debit : AppColors.credit;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.12),
                                child: Icon(
                                  tx.isDebit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    acc?.name ?? 'حساب #${tx.accountId}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    '${tx.isDebit ? 'عليه' : 'له'}: ${AppFormatters.formatAmount(tx.amount)} ${curr?.symbol ?? 'محلي'}',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tx.description ?? '-',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    AppFormatters.formatDisplayDate(tx.date),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

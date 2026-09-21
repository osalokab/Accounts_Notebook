import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pdf_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class CategoryReportScreen extends StatefulWidget {
  const CategoryReportScreen({super.key});

  @override
  State<CategoryReportScreen> createState() => _CategoryReportScreenState();
}

class _CategoryReportScreenState extends State<CategoryReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final accounts = context.watch<AccountProvider>().accounts;
    final currencySymbol = context.watch<CurrencyProvider>().selectedCurrency?.symbol ?? 'محلي';
    final settings = context.watch<SettingsProvider>().settings;

    // Group accounts by category
    final Map<int?, List> grouped = {};
    for (var acc in accounts) {
      grouped.putIfAbsent(acc.categoryId, () => []).add(acc);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير- إجمالي التصنيفات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تصدير PDF',
            onPressed: () async {
              final List<List<String>> rows = categories.map((cat) {
                final catAccounts = grouped[cat.id] ?? [];
                double debitSum = 0.0;
                double creditSum = 0.0;
                for (var acc in catAccounts) {
                  if (acc.currentBalance > 0) debitSum += acc.currentBalance;
                  if (acc.currentBalance < 0) creditSum += acc.currentBalance.abs();
                }
                return [
                  cat.name,
                  '${catAccounts.length}',
                  '${AppFormatters.formatAmount(debitSum)} $currencySymbol',
                  '${AppFormatters.formatAmount(creditSum)} $currencySymbol',
                  '${AppFormatters.formatAmount(debitSum - creditSum)} $currencySymbol',
                ];
              }).toList();

              final bytes = await PdfService.generateReportPdf(
                title: 'تقرير إجمالي التصنيفات',
                headers: ['التصنيف', 'الحسابات', 'إجمالي عليه', 'إجمالي له', 'الصافي'],
                rows: rows,
                settings: settings,
              );
              await Printing.layoutPdf(onLayout: (_) => bytes, name: 'تقرير_التصنيفات');
            },
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(child: Text('لا توجد تصنيفات معرفة'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catAccounts = grouped[cat.id] ?? [];
                double debitSum = 0.0;
                double creditSum = 0.0;
                for (var acc in catAccounts) {
                  if (acc.currentBalance > 0) debitSum += acc.currentBalance;
                  if (acc.currentBalance < 0) creditSum += acc.currentBalance.abs();
                }
                final net = debitSum - creditSum;

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
                                const Icon(Icons.folder_open, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  cat.name,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Chip(
                              label: Text('${catAccounts.length} حسابات'),
                              backgroundColor: AppColors.background,
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي عليه: ${AppFormatters.formatAmount(debitSum)} $currencySymbol',
                              style: const TextStyle(color: AppColors.debit, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'إجمالي له: ${AppFormatters.formatAmount(creditSum)} $currencySymbol',
                              style: const TextStyle(color: AppColors.credit, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الصافي: ${AppFormatters.formatAmount(net)} $currencySymbol',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: net >= 0 ? AppColors.debit : AppColors.credit,
                          ),
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

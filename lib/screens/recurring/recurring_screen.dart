import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recurring_transaction.dart';
import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecurringProvider>().loadRecurring();
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final recurringProvider = context.watch<RecurringProvider>();
    final accountMap = {for (var a in context.watch<AccountProvider>().accounts) a.id!: a};
    final currencyMap = {for (var c in context.watch<CurrencyProvider>().currencies) c.id!: c};

    final items = recurringProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التكرار التلقائي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: 'فحص وتنفيذ العمليات المستحقة الآن',
            onPressed: () async {
              final count = await recurringProvider.checkAndExecuteDue();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(count > 0 ? 'تم تنفيذ $count عمليات متكررة مستحقة' : 'لا توجد عمليات متكررة مستحقة الآن'),
                    backgroundColor: count > 0 ? AppColors.credit : AppColors.primary,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: recurringProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_repeat, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'لا توجد عمليات تكرار مجدولة',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة تكرار جديد'),
                        onPressed: () => _showAddRecurringDialog(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final acc = accountMap[item.accountId];
                    final curr = currencyMap[item.currencyId];
                    final isDebit = item.type == TransactionModel.typeDebit;
                    final color = isDebit ? AppColors.debit : AppColors.credit;

                    String freqLabel;
                    switch (item.frequency) {
                      case RecurringTransaction.freqDaily:
                        freqLabel = 'يومي';
                        break;
                      case RecurringTransaction.freqWeekly:
                        freqLabel = 'أسبوعي';
                        break;
                      case RecurringTransaction.freqMonthly:
                      default:
                        freqLabel = 'شهري';
                        break;
                    }

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(
                            isDebit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: color,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(acc?.name ?? 'حساب #${item.accountId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${isDebit ? 'عليه' : 'له'}: ${AppFormatters.formatAmount(item.amount)} ${curr?.symbol ?? 'محلي'}',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('التكرار: $freqLabel | التنفيذ القادم: ${AppFormatters.formatDisplayDate(item.nextExecutionDate)}'),
                            if (item.description != null) Text(item.description!, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: item.isActive,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                recurringProvider.updateRecurring(item.copyWith(isActive: val));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.debit),
                              onPressed: () => recurringProvider.deleteRecurring(item.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddRecurringDialog(context),
      ),
    );
  }

  void _showAddRecurringDialog(BuildContext context) {
    final accounts = context.read<AccountProvider>().accounts;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إنشاء حساب أولاً قبل جدولة العمليات المتكررة')),
      );
      return;
    }

    int selectedAccountId = accounts.first.id!;
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = TransactionModel.typeDebit;
    String selectedFreq = RecurringTransaction.freqMonthly;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('جدولة عملية متكررة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedAccountId,
                  decoration: const InputDecoration(labelText: 'اختر الحساب'),
                  items: accounts
                      .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => selectedAccountId = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'نوع العملية'),
                  items: const [
                    DropdownMenuItem(value: TransactionModel.typeDebit, child: Text('عليه (مدين)')),
                    DropdownMenuItem(value: TransactionModel.typeCredit, child: Text('له (دائن)')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedType = val!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedFreq,
                  decoration: const InputDecoration(labelText: 'فترة التكرار'),
                  items: const [
                    DropdownMenuItem(value: RecurringTransaction.freqDaily, child: Text('يومي')),
                    DropdownMenuItem(value: RecurringTransaction.freqWeekly, child: Text('أسبوعي')),
                    DropdownMenuItem(value: RecurringTransaction.freqMonthly, child: Text('شهري')),
                  ],
                  onChanged: (val) => setDialogState(() => selectedFreq = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'التفاصيل / البيان'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(AppValidators.normalizeDigits(amountCtrl.text.trim()));
                if (amount != null && amount > 0) {
                  final now = DateTime.now();
                  final item = RecurringTransaction(
                    accountId: selectedAccountId,
                    amount: amount,
                    type: selectedType,
                    currencyId: 1,
                    description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                    frequency: selectedFreq,
                    startDate: now,
                    nextExecutionDate: now,
                    isActive: true,
                  );
                  await context.read<RecurringProvider>().addRecurring(item);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

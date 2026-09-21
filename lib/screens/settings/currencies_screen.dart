import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/currency.dart';
import '../../providers/currency_provider.dart';
import '../../utils/constants.dart';

class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currencies = currencyProvider.currencies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملات'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final c = currencies[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: c.isDefault
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                child: Text(
                  c.symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.isDefault ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('الرمز: ${c.symbol}${c.isDefault ? ' (العملة الافتراضية)' : ''}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!c.isDefault)
                    IconButton(
                      icon: const Icon(Icons.star_border, color: AppColors.primary),
                      tooltip: 'تعيين كعملة افتراضية',
                      onPressed: () => currencyProvider.setDefaultCurrency(c.id!),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.accent),
                    onPressed: () => _showCurrencyDialog(context, currency: c),
                  ),
                  if (!c.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.debit),
                      onPressed: () async {
                        final ok = await currencyProvider.deleteCurrency(c.id!);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لا يمكن حذف هذه العملة لوجود حسابات أو عمليات مرتبطة بها'),
                              backgroundColor: AppColors.debit,
                            ),
                          );
                        }
                      },
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
        onPressed: () => _showCurrencyDialog(context),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, {Currency? currency}) {
    final nameCtrl = TextEditingController(text: currency?.name ?? '');
    final symbolCtrl = TextEditingController(text: currency?.symbol ?? '');
    bool isDefault = currency?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(currency != null ? 'تعديل العملة' : 'إضافة عملة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم العملة (مثال: ريال يمني, دولار)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: symbolCtrl,
                decoration: const InputDecoration(labelText: 'رمز العملة (مثال: ر.ي, \$)'),
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('تعيين كافتراضية'),
                value: isDefault,
                activeColor: AppColors.primary,
                onChanged: (val) => setDialogState(() => isDefault = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty && symbolCtrl.text.trim().isNotEmpty) {
                  final prov = context.read<CurrencyProvider>();
                  if (currency != null) {
                    await prov.updateCurrency(
                      currency.copyWith(
                        name: nameCtrl.text.trim(),
                        symbol: symbolCtrl.text.trim(),
                        isDefault: isDefault,
                      ),
                    );
                  } else {
                    await prov.addCurrency(
                      nameCtrl.text.trim(),
                      symbolCtrl.text.trim(),
                      isDefault: isDefault,
                    );
                  }
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

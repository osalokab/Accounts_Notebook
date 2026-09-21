import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../utils/constants.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التصنيفات'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(Icons.folder, color: AppColors.primary),
              ),
              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('النوع: ${cat.type == 'customer' ? 'عملاء' : cat.type == 'supplier' ? 'موردين' : 'عام'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.accent),
                    onPressed: () => _showCategoryDialog(context, category: cat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.debit),
                    onPressed: () async {
                      final ok = await categoryProvider.deleteCategory(cat.id!);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لا يمكن حذف هذا التصنيف لوجود حسابات مرتبطة به'),
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
        onPressed: () => _showCategoryDialog(context),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    String type = category?.type ?? 'general';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(category != null ? 'تعديل التصنيف' : 'إضافة تصنيف جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم التصنيف (مثال: موظفون، أقارب)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'نوع التصنيف'),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('عام')),
                  DropdownMenuItem(value: 'customer', child: Text('عملاء')),
                  DropdownMenuItem(value: 'supplier', child: Text('موردين')),
                ],
                onChanged: (val) => setDialogState(() => type = val ?? 'general'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  final prov = context.read<CategoryProvider>();
                  if (category != null) {
                    await prov.updateCategory(
                      category.copyWith(name: nameCtrl.text.trim(), type: type),
                    );
                  } else {
                    await prov.addCategory(nameCtrl.text.trim(), type: type);
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

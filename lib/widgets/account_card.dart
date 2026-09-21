import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/account_icons.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSettle;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final currencies = context.watch<CurrencyProvider>().currencies;

    final category = categories.where((c) => c.id == account.categoryId).firstOrNull;
    final categoryName = category?.name ?? (categories.isNotEmpty ? categories.first.name : (AppStrings.isArabic ? 'عام' : 'General'));

    final currency = currencies.where((c) => c.id == account.currencyId).firstOrNull;
    final currencySymbol = currency?.symbol ?? (currencies.isNotEmpty ? currencies.first.symbol : (AppStrings.isArabic ? 'محلي' : 'Local'));

    Color balanceColor;
    String balanceLabel;
    if (account.currentBalance > 0) {
      balanceColor = AppColors.debit;
      balanceLabel = '${AppStrings.isArabic ? "عليه" : "Owes"}: ${AppFormatters.formatAmount(account.currentBalance)} $currencySymbol';
    } else if (account.currentBalance < 0) {
      balanceColor = AppColors.credit;
      balanceLabel = '${AppStrings.isArabic ? "له" : "Owed"}: ${AppFormatters.formatAmount(account.currentBalance.abs())} $currencySymbol';
    } else {
      balanceColor = AppColors.textSecondary;
      balanceLabel = '${AppStrings.balanced} (0 $currencySymbol)';
    }

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        onLongPress: () => _showOptionsModal(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar with Icon or Letter
              CircleAvatar(
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                child: account.iconCode != null && account.iconCode!.isNotEmpty
                    ? Icon(
                        AccountIcons.getIcon(account.iconCode),
                        color: AppColors.primary,
                        size: 22,
                      )
                    : Text(
                        account.name.isNotEmpty ? account.name[0] : '؟',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Account Name & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border, width: 0.6),
                          ),
                          child: Text(
                            categoryName,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                        if (account.phone != null && account.phone!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            account.phone!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Balance Display
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    balanceLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppStrings.isArabic ? "خيارات الحساب" : "Account Options"}: ${account.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.accent),
              title: Text(AppStrings.editAccount),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: AppColors.primary),
              title: Text(AppStrings.settleAccount),
              onTap: () {
                Navigator.pop(ctx);
                onSettle?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.debit),
              title: Text(AppStrings.isArabic ? 'حذف الحساب بجميع عملياته' : 'Delete Account with all transactions'),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

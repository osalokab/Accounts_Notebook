import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final double? runningBalance;
  final String? currencySymbol;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.runningBalance,
    this.currencySymbol,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = currencySymbol ?? 'محلي';
    final isDebit = transaction.isDebit; // عليه
    final typeColor = isDebit ? AppColors.debit : AppColors.credit;
    final typeText = isDebit ? 'عليه' : 'له';
    final arrowIcon = isDebit ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onLongPress: () => _showOptionsModal(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type indicator badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: typeColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(arrowIcon, size: 14, color: typeColor),
                        const SizedBox(width: 4),
                        Text(
                          typeText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Amount
                  Text(
                    '${AppFormatters.formatAmount(transaction.amount)} $symbol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Description and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      transaction.description != null && transaction.description!.isNotEmpty
                          ? transaction.description!
                          : 'بدون تفاصيل',
                      style: TextStyle(
                        fontSize: 13,
                        color: transaction.description != null && transaction.description!.isNotEmpty
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    AppFormatters.formatDisplayDate(transaction.date),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),

              // Running balance if available
              if (runningBalance != null) ...[
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الرصيد بعد العملية:',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${AppFormatters.formatAmount(runningBalance!)} $symbol',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: runningBalance! > 0
                            ? AppColors.debit
                            : runningBalance! < 0
                                ? AppColors.credit
                                : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
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
                'خيارات العملية (${transaction.isDebit ? 'عليه' : 'له'} ${AppFormatters.formatAmount(transaction.amount)})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.accent),
              title: const Text('تعديل العملية'),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.debit),
              title: const Text('حذف العملية'),
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

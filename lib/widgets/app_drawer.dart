import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/routes.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import '../utils/app_strings.dart';
import '../utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط')),
        );
      }
    }
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.headset_mic_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(AppStrings.contactTitle, style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SelectableText(
              AppStrings.contactTextExact,
              style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.chat),
                label: Text(AppStrings.openWhatsApp),
                onPressed: () {
                  _openUrl(ctx, AppStrings.developerWhatsAppUrl);
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.email),
                label: Text(AppStrings.sendEmail),
                onPressed: () {
                  _openUrl(ctx, 'mailto:${AppStrings.developerEmail}');
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: Text(AppStrings.copyInfo),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: AppStrings.contactTextExact));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.copiedSuccess),
                      backgroundColor: AppColors.credit,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              settings.companyName ?? settings.userName ?? AppStrings.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            accountEmail: Text(
              settings.phone ?? settings.email ?? (AppStrings.isArabic ? 'إدارة الحسابات الشخصية والتجارية' : 'Personal and Business Accounts Management'),
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.menu_book, color: AppColors.primary, size: 38),
            ),
          ),

          // Scrollable Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 1. إضافة مبلغ
                ListTile(
                  leading: const Icon(Icons.add_circle, color: AppColors.credit),
                  title: Text(AppStrings.isArabic ? 'إضافة مبلغ' : 'Add Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.addTransaction);
                  },
                ),
                const Divider(),

                // 2. تقارير
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'تقرير- إجمالي المبالغ' : 'Report - Totals Summary'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.reportTotalSummary);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'تقرير- تفاصيل كل المبالغ' : 'Report - All Transactions'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.reportTransactionDetails);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'تقرير- إجمالي المبالغ شهرياً' : 'Report - Monthly Summary'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.reportMonthly);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category_outlined, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'تقرير- إجمالي التصنيفات' : 'Report - Categories Summary'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.reportCategorySummary);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.trending_up, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'تقرير- حركة الحسابات' : 'Report - Accounts Movement'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.reportAccountMovement);
                  },
                ),
                const Divider(),

                // 3. التكرار التلقائي
                ListTile(
                  leading: const Icon(Icons.event_repeat, color: AppColors.accent),
                  title: Text(AppStrings.recurringTransactions),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.recurring);
                  },
                ),
                const Divider(),

                // 4. النسخ الاحتياطي والاسترجاع
                ListTile(
                  leading: const Icon(Icons.backup, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'حفظ نسخة إحتياطية' : 'Create Backup'),
                  onTap: () async {
                    Navigator.pop(context);
                    final res = await BackupService.exportBackup(shareAfterExport: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res.message),
                          backgroundColor: res.success ? AppColors.credit : AppColors.debit,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.primary),
                  title: Text(AppStrings.isArabic ? 'إسترجاع قاعدة البيانات' : 'Restore Database'),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(AppStrings.isArabic ? 'تأكيد الاسترجاع' : 'Confirm Restore'),
                        content: Text(
                          AppStrings.isArabic
                              ? 'هل أنت متأكد من استرجاع نسخة احتياطية؟ سيتم استبدال البيانات الحالية بالنسخة المسترجعة.'
                              : 'Are you sure you want to restore a backup? Current data will be replaced.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel)),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debit),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(AppStrings.isArabic ? 'استرجاع' : 'Restore'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final res = await BackupService.importAndRestoreBackup();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.message),
                            backgroundColor: res.success ? AppColors.credit : AppColors.debit,
                          ),
                        );
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blueAccent),
                  title: Text(AppStrings.backupToDrive),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(AppStrings.backupToDrive),
                        content: Text(
                          AppStrings.isArabic
                              ? 'يمكنك حفظ ملف النسخة الاحتياطية مباشرة إلى حساب Google Drive الخاص بك عبر خيار "حفظ نسخة احتياطية" ومشاركتها واختيار تطبيق Google Drive على جهازك.'
                              : 'You can save backup files directly to Google Drive by choosing "Create Backup" and selecting the Google Drive app in the share sheet.',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.ok)),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),

                // 5. الإعدادات
                ListTile(
                  leading: const Icon(Icons.settings, color: AppColors.primary),
                  title: Text(AppStrings.settings),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),

                // 6. التواصل والدعم
                ListTile(
                  leading: const Icon(Icons.headset_mic_outlined, color: AppColors.primary),
                  title: Text(AppStrings.contactAndSupport),
                  onTap: () {
                    Navigator.pop(context);
                    _showContactDialog(context);
                  },
                ),

                // 7. حول البرنامج
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text(AppStrings.aboutApp),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: AppStrings.appName,
                      applicationVersion: AppConstants.appVersion,
                      applicationIcon: const Icon(Icons.menu_book, color: AppColors.primary, size: 40),
                      children: [
                        Text(
                          AppStrings.isArabic
                              ? 'تطبيق دفتر الحسابات الشخصي والتجاري.\nإدارة العمليات المالية، كشوفات الحسابات، تقارير تفصيلية وشهرية، حفظ نسخ احتياطية وطباعة PDF.\n\n${AppStrings.contactTextExact}'
                              : 'Personal & Business Accounts Notebook.\nManage transactions, statements, detailed & monthly reports, backups, and PDF printing.\n\n${AppStrings.contactTextExact}',
                        ),
                      ],
                    );
                  },
                ),

                // 8. مشاركة البرنامج
                ListTile(
                  leading: const Icon(Icons.share, color: AppColors.primary),
                  title: Text(AppStrings.shareApp),
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(
                      AppStrings.isArabic
                          ? 'أوصيك باستخدام تطبيق دفتر الحسابات لإدارة المداخيل والمصاريف وحسابات العملاء والموردين بكل سهولة وأمان!'
                          : 'I recommend using Accounts Notebook app to manage your income, expenses, and accounts easily and securely!',
                      subject: AppStrings.appName,
                    );
                  },
                ),

                // 9. خروج
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: AppColors.debit),
                  title: Text(AppStrings.exitApp, style: const TextStyle(color: AppColors.debit)),
                  onTap: () {
                    Navigator.pop(context);
                    exit(0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/routes.dart';
import '../../providers/settings_provider.dart';
import '../../services/backup_service.dart';
import '../../utils/app_strings.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _userNameCtrl;
  late TextEditingController _companyNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _userNameCtrl = TextEditingController(text: settings.userName ?? '');
    _companyNameCtrl = TextEditingController(text: settings.companyName ?? '');
    _phoneCtrl = TextEditingController(text: settings.phone ?? '');
    _addressCtrl = TextEditingController(text: settings.address ?? '');
    _emailCtrl = TextEditingController(text: settings.email ?? '');
  }

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _companyNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePersonalData() async {
    final prov = context.read<SettingsProvider>();
    final updated = prov.settings.copyWith(
      userName: _userNameCtrl.text.trim(),
      companyName: _companyNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    await prov.updateSettings(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ البيانات الشخصية بنجاح'),
          backgroundColor: AppColors.credit,
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الرابط')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final isArabic = settingsProv.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Section: المظهر (فاتح / داكن / تلقائي)
          _buildSectionHeader(isArabic ? 'المظهر والوضع' : 'Theme Mode'),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(AppStrings.lightMode),
                  secondary: const Icon(Icons.wb_sunny_outlined, color: AppColors.accent),
                  value: 'light',
                  groupValue: settings.themeMode,
                  onChanged: (val) {
                    if (val != null) settingsProv.setThemeMode(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(AppStrings.darkMode),
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                  value: 'dark',
                  groupValue: settings.themeMode,
                  onChanged: (val) {
                    if (val != null) settingsProv.setThemeMode(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(AppStrings.systemMode),
                  secondary: const Icon(Icons.brightness_auto, color: Colors.blueGrey),
                  value: 'system',
                  groupValue: settings.themeMode,
                  onChanged: (val) {
                    if (val != null) settingsProv.setThemeMode(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: لغة التطبيق (عربي - English)
          _buildSectionHeader(isArabic ? 'لغة التطبيق' : 'Application Language'),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('العربية (Arabic)'),
                  subtitle: const Text('اللغة الافتراضية مع دعم كامل للاتجاه من اليمين لليسار'),
                  secondary: const Icon(Icons.language, color: AppColors.primary),
                  value: 'ar',
                  groupValue: settings.languageCode,
                  onChanged: (val) {
                    if (val != null) settingsProv.setLanguageCode(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('English (الإنجليزية)'),
                  subtitle: const Text('English interface with Left-to-Right layout'),
                  secondary: const Icon(Icons.translate, color: AppColors.accent),
                  value: 'en',
                  groupValue: settings.languageCode,
                  onChanged: (val) {
                    if (val != null) settingsProv.setLanguageCode(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 1: البيانات الشخصية
          _buildSectionHeader(AppStrings.personalData),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextField(
                    controller: _companyNameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم المؤسسة / النشاط التجاري'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _userNameCtrl,
                    decoration: const InputDecoration(labelText: 'اسم صاحب الحساب / المسؤول'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف للتواصل'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(labelText: 'العنوان'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePersonalData,
                      child: const Text('حفظ البيانات الشخصية'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 2: خيارات الطباعة
          _buildSectionHeader('2. خيارات الطباعة وتصدير PDF'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('إظهار معلومات المنشأة في الترويسة'),
                  subtitle: const Text('اسم المؤسسة ورقم الهاتف في أعلى الكشف'),
                  value: settings.printShowCompanyInfo,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    settingsProv.updateSettings(settings.copyWith(printShowCompanyInfo: val));
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('إظهار تذييل التقرير والملاحظات'),
                  value: settings.printShowNotes,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    settingsProv.updateSettings(settings.copyWith(printShowNotes: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 3: الأمان وقفل التطبيق
          _buildSectionHeader('3. خيارات الأمان'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('قفل التطبيق برمز مرور (PIN)'),
                  subtitle: Text(
                    settings.isPasswordEnabled ? 'القفل مفعل حالياً' : 'القفل معطل',
                  ),
                  value: settings.isPasswordEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val) {
                      _showSetPinDialog(context);
                    } else {
                      _showDisablePinDialog(context);
                    }
                  },
                ),
                if (settings.isPasswordEnabled) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                    title: const Text('تغيير رمز المرور (PIN)'),
                    onTap: () => _showSetPinDialog(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 4: العملات والتصنيفات
          _buildSectionHeader('4. العملات والتصنيفات'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppColors.primary),
                  title: const Text('إدارة العملات'),
                  subtitle: const Text('إضافة وتعديل وحذف العملات وتعيين الافتراضية'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.currencies),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.category, color: AppColors.primary),
                  title: const Text('إدارة التصنيفات'),
                  subtitle: const Text('إضافة تصنيفات مخصصة (عام، عملاء، موردين...)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.categories),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 5: النسخ الاحتياطي
          _buildSectionHeader('5. خيارات حفظ البيانات والنسخ الاحتياطي'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file, color: AppColors.primary),
                  title: const Text('حفظ نسخة احتياطية محلية'),
                  subtitle: const Text('تصدير قاعدة البيانات ومشاركتها بأمان'),
                  onTap: () async {
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download, color: AppColors.primary),
                  title: const Text('استرجاع قاعدة البيانات'),
                  subtitle: const Text('استيراد نسخة احتياطية من ملف خارجي'),
                  onTap: () async {
                    final res = await BackupService.importAndRestoreBackup();
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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 6: استعراض البيانات من الكمبيوتر (Local Web Viewer info)
          _buildSectionHeader('6. استعراض البيانات من الكمبيوتر'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'يتيح لك هذا الخيار استعراض بياناتك من اللابتوب أو الكمبيوتر أو أي جهاز آخر متصل معك في نفس شبكة الواي فاي (Wi-Fi) المحلية.\n'
                    'تأكد من بقاء التطبيق مفتوحاً على هاتفك أثناء الاستعراض.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.laptop_chromebook),
                    label: const Text('معلومات الاتصال بالشبكة المحلية'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('استعراض البيانات من الكمبيوتر'),
                          content: const Text(
                            'لاستعراض البيانات من حاسوبك:\n\n'
                            '1- تأكد من اتصال الهاتف والحاسوب بنفس شبكة Wi-Fi.\n'
                            '2- قم بحفظ نسخة احتياطية واستعراضها عبر المتصفح أو تطبيق سطح المكتب المرفق.\n'
                            '3- تبقى بياناتك مخزنة محلياً في جهازك بدون الحاجة للإنترنت.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('حسناً')),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 7: التواصل والدعم الفني
          _buildSectionHeader(isArabic ? '7. التواصل والدعم الفني' : '7. Contact & Support'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SelectableText(
                    AppStrings.contactTextExact,
                    style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.chat),
                          label: Text(AppStrings.openWhatsApp),
                          onPressed: () => _openUrl(AppStrings.developerWhatsAppUrl),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.email),
                          label: Text(AppStrings.sendEmail),
                          onPressed: () => _openUrl('mailto:${AppStrings.developerEmail}'),
                        ),
                      ),
                    ],
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
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  void _showSetPinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعيين رمز مرور جديد (PIN)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinCtrl,
              decoration: const InputDecoration(labelText: 'أدخل رمز المرور (4 أرقام أو أكثر)'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmCtrl,
              decoration: const InputDecoration(labelText: 'تأكيد رمز المرور'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (pinCtrl.text.length >= 4 && pinCtrl.text == confirmCtrl.text) {
                await context.read<SettingsProvider>().setPin(pinCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تفعيل وقفل التطبيق برمز المرور بنجاح'),
                      backgroundColor: AppColors.credit,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('الرمز غير متطابق أو أقل من 4 أرقام'),
                    backgroundColor: AppColors.debit,
                  ),
                );
              }
            },
            child: const Text('تفعيل'),
          ),
        ],
      ),
    );
  }

  void _showDisablePinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعطيل قفل التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال رمز المرور الحالي لتأكيد التعطيل:'),
            const SizedBox(height: 10),
            TextField(
              controller: pinCtrl,
              decoration: const InputDecoration(labelText: 'رمز المرور الحالي'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.debit),
            onPressed: () async {
              final ok = await context.read<SettingsProvider>().unlockWithPin(pinCtrl.text.trim());
              if (ok) {
                await context.read<SettingsProvider>().disablePin();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تعطيل قفل التطبيق بنجاح')),
                  );
                }
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('رمز المرور غير صحيح'), backgroundColor: AppColors.debit),
                );
              }
            },
            child: const Text('تعطيل'),
          ),
        ],
      ),
    );
  }
}

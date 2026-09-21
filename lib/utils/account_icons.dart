import 'package:flutter/material.dart';

class AccountIconInfo {
  final String code;
  final IconData icon;
  final String nameAr;
  final String nameEn;

  const AccountIconInfo({
    required this.code,
    required this.icon,
    required this.nameAr,
    required this.nameEn,
  });
}

class AccountIcons {
  static const List<AccountIconInfo> all = [
    AccountIconInfo(code: 'person', icon: Icons.person, nameAr: 'شخصي / فرد', nameEn: 'Personal'),
    AccountIconInfo(code: 'store', icon: Icons.store, nameAr: 'محل / متجر', nameEn: 'Store'),
    AccountIconInfo(code: 'business', icon: Icons.business, nameAr: 'شركة / مؤسسة', nameEn: 'Business'),
    AccountIconInfo(code: 'shopping_cart', icon: Icons.shopping_cart, nameAr: 'مشتريات / بضاعة', nameEn: 'Shopping'),
    AccountIconInfo(code: 'local_shipping', icon: Icons.local_shipping, nameAr: 'توصيل / شحن', nameEn: 'Shipping'),
    AccountIconInfo(code: 'account_balance', icon: Icons.account_balance, nameAr: 'بنك / مصرف', nameEn: 'Bank'),
    AccountIconInfo(code: 'attach_money', icon: Icons.attach_money, nameAr: 'أموال / صرافة', nameEn: 'Money'),
    AccountIconInfo(code: 'home', icon: Icons.home, nameAr: 'عائلي / منزل', nameEn: 'Home'),
    AccountIconInfo(code: 'work', icon: Icons.work, nameAr: 'عمل / مشروع', nameEn: 'Work'),
    AccountIconInfo(code: 'handshake', icon: Icons.handshake, nameAr: 'شريك / عميل', nameEn: 'Partner'),
    AccountIconInfo(code: 'build', icon: Icons.build, nameAr: 'صيانة / خدمات', nameEn: 'Maintenance'),
    AccountIconInfo(code: 'medical_services', icon: Icons.medical_services, nameAr: 'طبي / صيدلية', nameEn: 'Medical'),
    AccountIconInfo(code: 'school', icon: Icons.school, nameAr: 'تعليم / دراسة', nameEn: 'Education'),
    AccountIconInfo(code: 'restaurant', icon: Icons.restaurant, nameAr: 'مطعم / كافيه', nameEn: 'Restaurant'),
    AccountIconInfo(code: 'directions_car', icon: Icons.directions_car, nameAr: 'سيارة / مواصلات', nameEn: 'Transport'),
    AccountIconInfo(code: 'wallet', icon: Icons.account_balance_wallet, nameAr: 'محفظة مالية', nameEn: 'Wallet'),
  ];

  static IconData getIcon(String? code) {
    if (code == null || code.isEmpty) return Icons.person;
    final found = all.where((item) => item.code == code).firstOrNull;
    return found?.icon ?? Icons.person;
  }

  static Future<String?> showIconPicker(BuildContext context, {String? selectedCode}) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'اختر أيقونة الحساب / Select Account Icon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: all.length,
                    itemBuilder: (context, index) {
                      final item = all[index];
                      final isSelected = item.code == selectedCode;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(ctx, item.code),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                size: 28,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.nameAr,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
          ),
        );
      },
    );
  }
}

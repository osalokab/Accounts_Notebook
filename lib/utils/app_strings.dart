class AppStrings {
  static bool isArabic = true;

  static void setLocale(String langCode) {
    isArabic = (langCode == 'ar');
  }

  // General
  static String get appName => isArabic ? 'دفتر الحسابات' : 'Accounts Notebook';
  static String get search => isArabic ? 'بحث' : 'Search';
  static String get clear => isArabic ? 'مسح' : 'Clear';
  static String get save => isArabic ? 'حفظ' : 'Save';
  static String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  static String get close => isArabic ? 'إغلاق' : 'Close';
  static String get delete => isArabic ? 'حذف' : 'Delete';
  static String get edit => isArabic ? 'تعديل' : 'Edit';
  static String get ok => isArabic ? 'حسناً' : 'OK';
  static String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  static String get notes => isArabic ? 'ملاحظات' : 'Notes';
  static String get date => isArabic ? 'التاريخ' : 'Date';
  static String get amount => isArabic ? 'المبلغ' : 'Amount';
  static String get phone => isArabic ? 'رقم الهاتف' : 'Phone Number';
  static String get currency => isArabic ? 'العملة' : 'Currency';
  static String get category => isArabic ? 'التصنيف' : 'Category';

  // Home
  static String get searchAccounts => isArabic ? 'بحث في الحسابات...' : 'Search accounts...';
  static String get addAmountPrompt => isArabic ? 'إضغط على علامة (+) لإضافة مبلغ' : 'Tap (+) to add an amount';
  static String get orCreateAccount => isArabic ? 'أو أنشئ حساباً جديداً للبدء بتسجيل الحركات' : 'Or create a new account to begin';
  static String get youOwe => isArabic ? 'عليك' : 'You owe';
  static String get owedToYou => isArabic ? 'لك' : 'You are owed';
  static String get balanced => isArabic ? 'متوازن' : 'Balanced';
  static String get userGuide => isArabic ? 'دليل الاستخدام' : 'User Guide';
  static String get sortAccounts => isArabic ? 'ترتيب الحسابات' : 'Sort Accounts';

  // Account
  static String get addNewAccount => isArabic ? 'إضافة حساب جديد' : 'Add New Account';
  static String get editAccount => isArabic ? 'تعديل الحساب' : 'Edit Account';
  static String get deleteAccount => isArabic ? 'حذف الحساب' : 'Delete Account';
  static String get settleAccount => isArabic ? 'تسوية / إغلاق الحساب' : 'Settle / Close Account';
  static String get accountName => isArabic ? 'اسم الحساب' : 'Account Name';
  static String get chooseAccountIcon => isArabic ? 'اختر أيقونة الحساب' : 'Choose Account Icon';
  static String get searchStatement => isArabic ? 'بحث في كشف الحساب...' : 'Search statement...';
  static String get exportPdf => isArabic ? 'تصدير PDF' : 'Export PDF';
  static String get printStatement => isArabic ? 'طباعة كشف الحساب' : 'Print Statement';
  static String get currentBalance => isArabic ? 'الرصيد الحالي' : 'Current Balance';

  // Drawer
  static String get generalReports => isArabic ? 'التقارير العامة' : 'General Reports';
  static String get monthlyBalances => isArabic ? 'أرصدة الأشهر السابقة' : 'Previous Months Balances';
  static String get recurringTransactions => isArabic ? 'العمليات الدورية' : 'Recurring Transactions';
  static String get lockApp => isArabic ? 'قفل البرنامج' : 'Lock Application';
  static String get backupToDrive => isArabic ? 'نسخ احتياطي على Google Drive' : 'Backup to Google Drive';
  static String get settings => isArabic ? 'إعدادات' : 'Settings';
  static String get contactAndSupport => isArabic ? 'للتواصل والدعم' : 'Contact & Support';
  static String get aboutApp => isArabic ? 'حول البرنامج' : 'About App';
  static String get shareApp => isArabic ? 'مشاركة البرنامج' : 'Share App';
  static String get exitApp => isArabic ? 'خروج' : 'Exit';

  // Settings
  static String get themeSettings => isArabic ? 'المظهر والوضع' : 'Theme & Appearance';
  static String get lightMode => isArabic ? 'الوضع الفاتح' : 'Light Mode';
  static String get darkMode => isArabic ? 'الوضع الداكن' : 'Dark Mode';
  static String get systemMode => isArabic ? 'تلقائي حسب النظام' : 'System Default';
  static String get languageSettings => isArabic ? 'لغة التطبيق' : 'App Language';
  static String get arabicLanguage => isArabic ? 'العربية' : 'Arabic';
  static String get englishLanguage => isArabic ? 'English' : 'English';
  static String get personalData => isArabic ? 'البيانات الشخصية والمؤسسة' : 'Personal & Business Info';
  static String get printOptions => isArabic ? 'خيارات الطباعة والتقارير' : 'Print & Report Options';
  static String get securityOptions => isArabic ? 'خيارات الأمان ورمز المرور' : 'Security & Passcode Options';
  static String get manageCurrencies => isArabic ? 'إدارة العملات' : 'Manage Currencies';
  static String get manageCategories => isArabic ? 'إدارة التصنيفات' : 'Manage Categories';
  static String get backupOptions => isArabic ? 'خيارات حفظ البيانات والنسخ الاحتياطي' : 'Data Backup & Restore';

  // Developer contact
  static const String developerEmail = 'osamaalokab24@gmail.com';
  static const String developerWhatsAppUrl = 'https://wa.me/967780086263';
  static const String contactTextExact =
      'يرجى التواصل مع المطور أسامة العقاب عبر البريد الالكتروني osamaalokab24@gmail.com او عبر الواتساب https://wa.me/967780086263';
  static String get contactTitle => isArabic ? 'التواصل والدعم الفني' : 'Developer & Technical Support';
  static String get openWhatsApp => isArabic ? 'مراسلة عبر الواتساب' : 'Open WhatsApp';
  static String get sendEmail => isArabic ? 'إرسال بريد إلكتروني' : 'Send Email';
  static String get copyInfo => isArabic ? 'نسخ بيانات التواصل' : 'Copy Contact Info';
  static String get copiedSuccess => isArabic ? 'تم نسخ بيانات التواصل بنجاح' : 'Contact info copied successfully';
}

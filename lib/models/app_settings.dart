class AppSettings {
  final bool isPasswordEnabled;
  final String? passwordHash;
  final int? defaultCurrencyId;
  final bool autoBackupDaily;
  final bool autoBackupDrive;
  
  // Personal & Company profile
  final String? userName;
  final String? companyName;
  final String? phone;
  final String? address;
  final String? email;
  final String? logoPath;

  // Print settings
  final bool printShowLogo;
  final bool printShowCompanyInfo;
  final bool printShowNotes;

  // App Theme & Language
  final String themeMode; // 'light', 'dark', 'system'
  final String languageCode; // 'ar', 'en'

  AppSettings({
    this.isPasswordEnabled = false,
    this.passwordHash,
    this.defaultCurrencyId,
    this.autoBackupDaily = true,
    this.autoBackupDrive = false,
    this.userName,
    this.companyName,
    this.phone,
    this.address,
    this.email,
    this.logoPath,
    this.printShowLogo = true,
    this.printShowCompanyInfo = true,
    this.printShowNotes = true,
    this.themeMode = 'light',
    this.languageCode = 'ar',
  });

  AppSettings copyWith({
    bool? isPasswordEnabled,
    String? passwordHash,
    int? defaultCurrencyId,
    bool? autoBackupDaily,
    bool? autoBackupDrive,
    String? userName,
    String? companyName,
    String? phone,
    String? address,
    String? email,
    String? logoPath,
    bool? printShowLogo,
    bool? printShowCompanyInfo,
    bool? printShowNotes,
    String? themeMode,
    String? languageCode,
  }) {
    return AppSettings(
      isPasswordEnabled: isPasswordEnabled ?? this.isPasswordEnabled,
      passwordHash: passwordHash ?? this.passwordHash,
      defaultCurrencyId: defaultCurrencyId ?? this.defaultCurrencyId,
      autoBackupDaily: autoBackupDaily ?? this.autoBackupDaily,
      autoBackupDrive: autoBackupDrive ?? this.autoBackupDrive,
      userName: userName ?? this.userName,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      printShowLogo: printShowLogo ?? this.printShowLogo,
      printShowCompanyInfo: printShowCompanyInfo ?? this.printShowCompanyInfo,
      printShowNotes: printShowNotes ?? this.printShowNotes,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_password_enabled': isPasswordEnabled ? 1 : 0,
      'password_hash': passwordHash,
      'default_currency_id': defaultCurrencyId,
      'auto_backup_daily': autoBackupDaily ? 1 : 0,
      'auto_backup_drive': autoBackupDrive ? 1 : 0,
      'user_name': userName,
      'company_name': companyName,
      'phone': phone,
      'address': address,
      'email': email,
      'logo_path': logoPath,
      'print_show_logo': printShowLogo ? 1 : 0,
      'print_show_company_info': printShowCompanyInfo ? 1 : 0,
      'print_show_notes': printShowNotes ? 1 : 0,
      'theme_mode': themeMode,
      'language_code': languageCode,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isPasswordEnabled: (map['is_password_enabled'] as int? ?? 0) == 1,
      passwordHash: map['password_hash'] as String?,
      defaultCurrencyId: map['default_currency_id'] as int?,
      autoBackupDaily: (map['auto_backup_daily'] as int? ?? 1) == 1,
      autoBackupDrive: (map['auto_backup_drive'] as int? ?? 0) == 1,
      userName: map['user_name'] as String?,
      companyName: map['company_name'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      email: map['email'] as String?,
      logoPath: map['logo_path'] as String?,
      printShowLogo: (map['print_show_logo'] as int? ?? 1) == 1,
      printShowCompanyInfo: (map['print_show_company_info'] as int? ?? 1) == 1,
      printShowNotes: (map['print_show_notes'] as int? ?? 1) == 1,
      themeMode: (map['theme_mode'] as String?) ?? 'light',
      languageCode: (map['language_code'] as String?) ?? 'ar',
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette (matching reference screenshots)
  static const Color primary = Color(0xFF28487D);
  static const Color primaryDark = Color(0xFF1B3258);
  static const Color primaryLight = Color(0xFF3B64A5);
  
  // Secondary & Accents
  static const Color accent = Color(0xFF2563EB);
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Financial indicators
  static const Color debit = Color(0xFFDC2626); // عليه (Red)
  static const Color credit = Color(0xFF16A34A); // له (Green)
  static const Color balance = Color(0xFF0F172A);

  // Neutral grays
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFCBD5E1);
  static const Color divider = Color(0xFFE2E8F0);
  
  // Bottom Bar / Highlight
  static const Color bottomBar = Color(0xFF243F6E);
  static const Color bottomBarText = Colors.white;
}

class AppConstants {
  static const String appName = 'دفتر الحسابات';
  static const String appVersion = '1.0.0';
  
  // Storage keys
  static const String keyIsPasswordEnabled = 'is_password_enabled';
  static const String keyAppPinHash = 'app_pin_hash';
  static const String keyDefaultCurrencyId = 'default_currency_id';
  static const String keyCompanyName = 'company_name';
  static const String keyUserName = 'user_name';
  static const String keyPhone = 'user_phone';
  static const String keyAddress = 'user_address';
  static const String keyEmail = 'user_email';
  static const String keyLogoPath = 'user_logo_path';
  static const String keyAutoBackupDaily = 'auto_backup_daily';
  static const String keyFirstRunDone = 'first_run_done';
}

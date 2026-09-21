import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/recurring_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import 'routes.dart';
import 'theme.dart';

class AccountsNotebookApp extends StatelessWidget {
  const AccountsNotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()..loadCurrencies()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => AccountProvider()..loadAccounts()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => RecurringProvider()..loadRecurring()..checkAndExecuteDue()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProv, _) {
          return MaterialApp(
            title: settingsProv.isArabic ? AppConstants.appName : 'Accounts Notebook',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProv.themeMode,
            locale: settingsProv.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}

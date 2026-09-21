import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../screens/accounts/account_details_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/recurring/recurring_screen.dart';
import '../screens/reports/account_movement_report_screen.dart';
import '../screens/reports/category_report_screen.dart';
import '../screens/reports/monthly_report_screen.dart';
import '../screens/reports/total_summary_report_screen.dart';
import '../screens/reports/transaction_details_report_screen.dart';
import '../screens/security/lock_screen.dart';
import '../screens/settings/categories_screen.dart';
import '../screens/settings/currencies_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addTransaction = '/add-transaction';
  static const String accountDetails = '/account-details';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String currencies = '/currencies';
  static const String categories = '/categories';
  static const String recurring = '/recurring';
  
  // Reports
  static const String reportTotalSummary = '/reports/total-summary';
  static const String reportTransactionDetails = '/reports/transaction-details';
  static const String reportMonthly = '/reports/monthly';
  static const String reportCategorySummary = '/reports/category-summary';
  static const String reportAccountMovement = '/reports/account-movement';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const LockScreen(child: HomeScreen()));
      
      case addTransaction:
        final arg = routeSettings.arguments;
        if (arg is TransactionModel) {
          return MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: arg));
        } else if (arg is Account) {
          return MaterialPageRoute(builder: (_) => AddTransactionScreen(preselectedAccount: arg));
        }
        return MaterialPageRoute(builder: (_) => const AddTransactionScreen());

      case accountDetails:
        final account = routeSettings.arguments as Account;
        return MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account));

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case currencies:
        return MaterialPageRoute(builder: (_) => const CurrenciesScreen());

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());

      case recurring:
        return MaterialPageRoute(builder: (_) => const RecurringScreen());

      case reportTotalSummary:
        return MaterialPageRoute(builder: (_) => const TotalSummaryReportScreen());

      case reportTransactionDetails:
        return MaterialPageRoute(builder: (_) => const TransactionDetailsReportScreen());

      case reportMonthly:
        return MaterialPageRoute(builder: (_) => const MonthlyReportScreen());

      case reportCategorySummary:
        return MaterialPageRoute(builder: (_) => const CategoryReportScreen());

      case reportAccountMovement:
        return MaterialPageRoute(builder: (_) => const AccountMovementReportScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('لا توجد صفحة بالاسم ${routeSettings.name}')),
          ),
        );
    }
  }
}

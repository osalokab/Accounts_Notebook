import 'package:flutter_test/flutter_test.dart';
import 'package:accounts_notebook/models/account.dart';
import 'package:accounts_notebook/models/transaction.dart';
import 'package:accounts_notebook/repositories/transaction_repository.dart';
import 'package:accounts_notebook/utils/formatters.dart';
import 'package:accounts_notebook/utils/validators.dart';

void main() {
  group('Financial Calculations & Running Balances', () {
    test('roundMoney safely rounds to 2 decimals avoiding float drifts', () {
      expect(AppFormatters.roundMoney(10.126), 10.13);
      expect(AppFormatters.roundMoney(10.124), 10.12);
      expect(AppFormatters.roundMoney(0.1 + 0.2), 0.3);
    });

    test('Statement calculation accurately computes running balance', () {
      final repo = TransactionRepository();
      const initialBalance = 100.0;

      final t1 = TransactionModel(
        id: 1,
        accountId: 1,
        amount: 50.0,
        type: TransactionModel.typeDebit, // عليه (+50)
        currencyId: 1,
        date: DateTime(2026, 9, 1),
      );

      final t2 = TransactionModel(
        id: 2,
        accountId: 1,
        amount: 30.0,
        type: TransactionModel.typeCredit, // له (-30)
        currencyId: 1,
        date: DateTime(2026, 9, 2),
      );

      final t3 = TransactionModel(
        id: 3,
        accountId: 1,
        amount: 25.50,
        type: TransactionModel.typeDebit, // عليه (+25.50)
        currencyId: 1,
        date: DateTime(2026, 9, 3),
      );

      final statement = repo.calculateStatement(initialBalance, [t1, t2, t3]);

      expect(statement.length, 3);
      // 100 + 50 = 150
      expect(statement[0]['running_balance'], 150.0);
      // 150 - 30 = 120
      expect(statement[1]['running_balance'], 120.0);
      // 120 + 25.50 = 145.50
      expect(statement[2]['running_balance'], 145.50);
    });

    test('Account model balance updates correctly', () {
      final account = Account(
        id: 1,
        name: 'أحمد علي',
        initialBalance: 0.0,
        currentBalance: 500.0,
      );

      final updated = account.copyWith(currentBalance: 750.0);
      expect(updated.currentBalance, 750.0);
      expect(updated.name, 'أحمد علي');
    });

    test('Validators correctly handle Arabic and Western numerals', () {
      expect(AppValidators.normalizeDigits('١٢٣٤٥'), '12345');
      expect(AppValidators.normalizeDigits('٥٠.٥'), '50.5');
      expect(AppValidators.validAmount('١٥٠'), null);
      expect(AppValidators.validAmount('-10'), 'المبلغ يجب أن يكون أكبر من الصفر');
      expect(AppValidators.validAmount('0'), 'المبلغ يجب أن يكون أكبر من الصفر');
      expect(AppValidators.validAmount('abc'), 'يرجى إدخال رقم صحيح');
    });

    test('Number formatting formats positive and negative balances', () {
      expect(AppFormatters.formatAmount(1500), '1,500');
      expect(AppFormatters.formatAmount(-250.75, currencySymbol: 'ر.س'), '250.75 ر.س');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:accounts_notebook/app/app.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Accounts Notebook smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AccountsNotebookApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify app widget exists
    expect(find.byType(AccountsNotebookApp), findsOneWidget);
  });
}

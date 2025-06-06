import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tpm_fp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Currency converter test: convert from USD to circuit currency', (WidgetTester tester) async {
app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Validate that we are on the login page
    expect(find.byKey(const Key('login-title')), findsOneWidget);

    // Proceed to register
    final registerBtn = find.byKey(const Key('register-button'));
    expect(registerBtn, findsOneWidget);
    await tester.tap(registerBtn);
    await tester.pumpAndSettle();

    // Register a new account
    final testUsername = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
    await tester.enterText(find.byKey(const Key('username-field')), testUsername);
    await tester.enterText(find.byKey(const Key('fullname-field')), 'Test User');
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.enterText(find.byKey(const Key('confirm-password-field')), '123456');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('register-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('register-button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should navigate to Login screen
    expect(find.byKey(const Key('login-title')), findsOneWidget);

    // Fill in login credentials
    await tester.enterText(find.byKey(const Key('username-field')), testUsername);
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Validate successful login by checking HomeScreen
    expect(find.byKey(const Key('home_screen')), findsWidgets);

    // Open currency converter page
    await tester.tap(find.widgetWithIcon(Card, Icons.attach_money));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('currency_screen')), findsOneWidget);

    // Input amount to convert
    await tester.enterText(find.byKey(const Key('amount_input')), '100');
    await tester.pumpAndSettle();

    // Choose circuit's currency from dropdown
    await tester.tap(find.byKey(const Key('circuit_dropdown')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const Key('circuit_qatar')).last);
    await tester.pumpAndSettle();

    // Press convert button
    await tester.tap(find.byKey(const Key('convert_button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Chech if conversion result is displayed
    expect(find.textContaining('Currency for'), findsOneWidget); 
  });
}

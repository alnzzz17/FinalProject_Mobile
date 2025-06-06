import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tpm_fp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Timezone conversion should display converted time', (WidgetTester tester) async {
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
    await tester.enterText(
        find.byKey(const Key('username-field')), testUsername);
    await tester.enterText(
        find.byKey(const Key('fullname-field')), 'Test User');
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.enterText(
        find.byKey(const Key('confirm-password-field')), '123456');

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

    // Navigate to Timezone conversion page
    await tester.tap(find.widgetWithIcon(Card, Icons.access_time));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(const Key('time_converter_screen')), findsOneWidget);

    // Wait for data to load
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Select circuit (From)
    await tester.tap(find.byKey(const Key('circuit_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('circuit_item_qatar')));
    await tester.pumpAndSettle();

    // Select timezone (To)
    await tester.tap(find.byKey(const Key('timezone_selector')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await tester.enterText(find.byKey(const Key('timezone_search_field')), 'New York');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('timezone_item_America/New_York')));
    await tester.pumpAndSettle();

    // Select date and time
    await tester.tap(find.byKey(const Key('datetime_picker_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').first); // date
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last); // time
    await tester.pumpAndSettle();

    // Press convert button
    await tester.tap(find.byKey(const Key('convert_button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check if conversion result is displayed
    expect(find.byKey(const Key('result_card')), findsOneWidget);
    expect(find.byKey(const Key('converted_time_text')), findsOneWidget);
    expect(find.textContaining('From:'), findsOneWidget);
    expect(find.textContaining('To:'), findsOneWidget);

    // Check current time card appears
    expect(find.byKey(const Key('current_time_card')), findsOneWidget);
  });
}
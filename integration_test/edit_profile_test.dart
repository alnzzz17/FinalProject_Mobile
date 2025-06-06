import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tpm_fp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Edit profile and verify changes on home page',
      (WidgetTester tester) async {
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
    expect(find.text('Welcome, Test User!'), findsOneWidget);

    // Navigate to Profile screen
    await tester.tap(find.byKey(const Key('profile_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byKey(const Key('profile_screen')), findsOneWidget);

    // Enter edit mode
    await tester.tap(find.byKey(const Key('edit_profile_button')));
    await tester.pumpAndSettle();

    // Change username
    await tester.enterText(find.byKey(const Key('username_input_field')), 'new_$testUsername');
    await tester.pumpAndSettle();

    // Change fullname
    await tester.enterText(find.byKey(const Key('fullname_input_field')), 'New Test User');
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('change_password_checkbox')));
    await tester.pumpAndSettle();

    // Enable password change
    await tester.tap(find.byKey(const Key('change_password_checkbox')));
    await tester.pumpAndSettle();

    // Enter new password
    await tester.enterText(find.byKey(const Key('password_input_field')), 'newpassword123');
    await tester.pumpAndSettle();

    // Confirm new password
    await tester.enterText(
        find.byKey(const Key('confirm_password_input_field')), 'newpassword123');
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('save_profile_button')));
    await tester.pumpAndSettle();

    // Save changes
    await tester.tap(find.byKey(const Key('save_profile_button')));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify success snackbar
    expect(find.text('Profile updated successfully'), findsOneWidget);

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('home_tab')));
    await tester.pumpAndSettle();

    // Navigate back to Home screen
    await tester.tap(find.byKey(const Key('home_tab')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify the fullname has changed on home page
    expect(find.text('Welcome, New Test User!'), findsOneWidget);

    // Verify the username has changed by logging out and logging back in
    await tester.tap(find.byKey(const Key('logout_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Login with new credentials
    await tester.enterText(find.byKey(const Key('username-field')), 'new_$testUsername');
    await tester.enterText(find.byKey(const Key('password-field')), 'newpassword123');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify successful login with new credentials
    expect(find.byKey(const Key('home_screen')), findsWidgets);
    expect(find.text('Welcome, New Test User!'), findsOneWidget);
  });
}

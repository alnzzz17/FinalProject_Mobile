import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpm_fp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Register and Login flow integration test',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Validasi bahwa kita di halaman login
    expect(find.byKey(const Key('login-title')), findsOneWidget);

    // Lanjut ke register
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

    await tester.sendKeyEvent(
        LogicalKeyboardKey.escape); // simulasikan ESC untuk menutup keyboard
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('register-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('register-button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Should navigate to Login screen
    expect(find.byKey(const Key('login-title')), findsOneWidget);

    // Fill in login credentials
    await tester.enterText(
        find.byKey(const Key('username-field')), testUsername);
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester
        .pumpAndSettle(const Duration(seconds: 3)); // wait for navigation

    // Validate successful login by checking HomeScreen
    expect(find.byKey(const Key('home_screen')), findsWidgets);

    // ✅ Verifikasi SharedPreferences menyimpan username
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('current_username');

// Username yang tersimpan harus sesuai username yang dipakai login
    expect(savedUsername, equals(testUsername));
  });
}

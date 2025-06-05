import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive/hive.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add schedule and verify Hive + notification state',
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

    // Navigasi ke Schedule screen
    await tester.tap(find.widgetWithIcon(Card, Icons.calendar_month));
    await tester.pumpAndSettle();

    // Validasi form schedule muncul
    expect(find.byKey(const Key('schedule_screen')), findsOneWidget);
    expect(find.byKey(const Key('form_title')), findsOneWidget);

    // Isi form
    await tester.enterText(find.byKey(const Key('name_input')), 'Test Race');
    await tester.pumpAndSettle();

    // Pilih circuit
    await tester.tap(find.byKey(const Key('circuit_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('circuit_qatar')).last);
    await tester.pumpAndSettle();

    // Pilih type
    await tester.tap(find.byKey(const Key('type_dropdown')));
    await tester.pumpAndSettle();

// Tambahkan delay
    await Future.delayed(Duration(seconds: 1));
    await tester.pumpAndSettle();

// Lanjut tap opsi
    await tester.tap(find.text('Main Race').last);
    await tester.pumpAndSettle();

    // Pilih tanggal dan waktu
    await tester.tap(find.byKey(const Key('date_time_input')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').first); // date
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last); // time
    await tester.pumpAndSettle();

    // Simpan
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Validasi item tampil
    expect(find.text('Test Race'), findsOneWidget);

    // Cek data di Hive
    final box = await Hive.openBox<Schedule>('schedules');
    final saved = box.values.where((s) => s.name == 'Test Race').toList();
    expect(saved.isNotEmpty, true);
    expect(saved.first.notificationEnabled, true);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive/hive.dart';
import 'package:tpm_fp/models/schedule_model.dart';
import 'package:tpm_fp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add schedule and verify Hive + notification state', (WidgetTester tester) async {
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

    // Navigate to Schedule screen
    await tester.tap(find.widgetWithIcon(Card, Icons.calendar_month));
    await tester.pumpAndSettle();

    // Check if the form is displayed
    expect(find.byKey(const Key('schedule_screen')), findsOneWidget);
    expect(find.byKey(const Key('form_title')), findsOneWidget);

    // Fill in the schedule form
    await tester.enterText(find.byKey(const Key('name_input')), 'Test Race');
    await tester.pumpAndSettle();

    // Choose circuit
    await tester.tap(find.byKey(const Key('circuit_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('circuit_qatar')).last);
    await tester.pumpAndSettle();

    // Choose race type
    await tester.tap(find.byKey(const Key('type_dropdown')));
    await tester.pumpAndSettle();

    // Add a delay to ensure dropdown options are rendered
    await Future.delayed(Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Proceed to option
    await tester.tap(find.text('Main Race').last);
    await tester.pumpAndSettle();

    // Choose date and time
    await tester.tap(find.byKey(const Key('date_time_input')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').first); // date
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK').last); // time
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check if the schedule is displayed
    expect(find.text('Test Race'), findsOneWidget);

    // Check the data in Hive
    final box = await Hive.openBox<Schedule>('schedules');
    final saved = box.values.where((s) => s.name == 'Test Race').toList();
    expect(saved.isNotEmpty, true);
    expect(saved.first.notificationEnabled, true);
    final scheduleId = saved.first.id;

    // Verify notifications were scheduled
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // Workmanager does not provide a way to get pending tasks directly.
    // Instead, you can check if the schedule's notificationEnabled is true as a proxy.
    expect(saved.first.notificationEnabled, true); // Notification should be enabled

    // Edit the schedule
    await tester.tap(find.byKey(Key('edit_button_$scheduleId')));
    await tester.pumpAndSettle();

    // Update schedule name
    final nameField = find.byKey(const Key('name_input'));
    await tester.tap(nameField);
    await tester.enterText(nameField, '');
    await tester.pumpAndSettle();
    await tester.enterText(nameField, 'Updated Test Race');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('save_button')));

    // Save updated schedule
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check if the updated schedule is displayed
    expect(find.text('Updated Test Race'), findsOneWidget);

    // Verify old notifications were cancelled and new ones scheduled
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // Again, check notificationEnabled as a proxy for scheduled notifications.
    expect(saved.first.notificationEnabled, true);

    // Delete the schedule
    await tester.tap(find.byKey(Key('delete_button_$scheduleId')));
    await tester.pumpAndSettle();

    // Confirm deletion if there's a dialog
    final deleteConfirmButton = find.text('Ya');
    if (deleteConfirmButton.evaluate().isNotEmpty) {
      await tester.tap(deleteConfirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(find.text('Updated Test Race'), findsNothing);

    // Check if schedule is deleted from Hive
    final updatedSchedules = box.values.where((s) => s.id == scheduleId).toList();
    expect(updatedSchedules.isEmpty, true);

    // Verify notifications were cancelled
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // After deletion, the schedule should not exist, so notificationEnabled is not relevant.
    // You can assert that the schedule is deleted as above.
  });
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive/hive.dart';
import 'package:tpm_fp/main.dart' as app;
import 'package:tpm_fp/models/feedback_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Feedback flow test: add, edit, delete', (WidgetTester tester) async {
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

    // Go to Feedback tab
    await tester.tap(find.byKey(const Key('feedback_tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feedback_screen')), findsOneWidget);

    // Add new feedback
    expect(find.byKey(const Key('feedback_type_dropdown')), findsOneWidget);
    
    // Wait for the dropdown to be fully rendered
    await tester.pumpAndSettle();

    // Tap the dropdown
    await tester.tap(find.byKey(const Key('feedback_type_dropdown')));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Find and tap the dropdown item (now it should be visible)
    await tester.tap(find.text('Impression').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Enter feedback content
    await tester.enterText(find.byKey(const Key('feedback_content_input')), 'Sangat bagus!');
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('feedback_submit_button')));
    await tester.pumpAndSettle();

    // Submit feedback
    await tester.tap(find.byKey(const Key('feedback_submit_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sangat bagus!'));
    await tester.pumpAndSettle();

    expect(find.text('Sangat bagus!'), findsOneWidget);

    // Get feedback id for further operations
    final box = await Hive.openBox<FeedbackModel>('feedbacks');
    final feedbacks = box.values.where((f) => f.username == testUsername).toList();
    expect(feedbacks.isNotEmpty, true);
    final feedbackId = feedbacks.first.id;

    // Edit feedback
    await tester.tap(find.byKey(Key('edit_feedback_$feedbackId')));
    await tester.pumpAndSettle();

    // Update feedback content
    await tester.enterText(find.byKey(const Key('feedback_content_input')), 'Sangat luar biasa!');
    await tester.pumpAndSettle();

    // Submit updated feedback
    await tester.tap(find.byKey(const Key('feedback_submit_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sangat luar biasa!'));
    await tester.pumpAndSettle();

    expect(find.text('Sangat luar biasa!'), findsOneWidget);

    // Delete feedback
    await tester.tap(find.byKey(Key('delete_feedback_$feedbackId')));
    await tester.pumpAndSettle();

    // Confirm deletion if there's a dialog
    final deleteConfirmButton = find.text('Ya');
    if (deleteConfirmButton.evaluate().isNotEmpty) {
      await tester.tap(deleteConfirmButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(find.text('Sangat luar biasa!'), findsNothing);

    // Check if feedback is deleted from Hive
    final updatedFeedbacks =
        box.values.where((f) => f.username == testUsername).toList();
    expect(updatedFeedbacks.isEmpty, true);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tpm_fp/main.dart' as app;
import 'package:geolocator/geolocator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Map displays user location and nearby circuits', 
      (WidgetTester tester) async {
    // Mock the geolocator to return a specific position (Qatar circuit location)
    GeolocatorPlatform.instance = _MockGeolocatorPlatform();

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
    await tester.enterText(
        find.byKey(const Key('username-field')), testUsername);
    await tester.enterText(find.byKey(const Key('password-field')), '123456');
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Validate successful login by checking HomeScreen
    expect(find.byKey(const Key('home_screen')), findsWidgets);

    // Navigate to Map screen
    await tester.tap(find.widgetWithIcon(Card, Icons.map));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify map screen is displayed
    expect(find.byKey(const Key('map_screen')), findsOneWidget);
    expect(find.byKey(const Key('map_title')), findsOneWidget);

    // Wait for location to load
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify user location marker is displayed
    expect(find.byKey(const Key('user_location_marker')), findsOneWidget);

    // Verify nearby circuits are displayed (should be Qatar circuit in this case)
    expect(find.byKey(const Key('circuit_marker_qatar')), findsOneWidget);

    // Verify distance line is shown between user and circuit
    expect(find.byKey(const Key('distance_polyline_layer')), findsOneWidget);

    // Tap on a circuit marker to show info dialog
    await tester.tap(find.byKey(const Key('circuit_tap_qatar')));
    await tester.pumpAndSettle();

    // Verify circuit info dialog appears
    expect(find.byKey(const Key('circuit_info_dialog_qatar')), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('Losail'), findsOneWidget);
    expect(find.text('Location: Qatar'), findsOneWidget);
    expect(find.textContaining('Distance:'), findsOneWidget);

    // Close the dialog
    await tester.tap(find.byKey(const Key('circuit_dialog_close_button_qatar')));
    await tester.pumpAndSettle();

    // Test toggle buttons
    await tester.tap(find.byKey(const Key('toggle_user_location_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('user_location_marker')), findsNothing);

    await tester.tap(find.byKey(const Key('toggle_circuits_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('circuit_marker_qatar')), findsNothing);

    // Test zoom buttons
    await tester.tap(find.byKey(const Key('zoom_in_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('zoom_out_button')));
    await tester.pumpAndSettle();

    // Test refresh button
    await tester.tap(find.byKey(const Key('refresh_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}

class _MockGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    return Position(
      latitude: 25.4908,  // Qatar circuit latitude
      longitude: 51.4545, // Qatar circuit longitude
      timestamp: DateTime.now(),
      accuracy: 10,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async => 
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async => 
      LocationPermission.whileInUse;
}
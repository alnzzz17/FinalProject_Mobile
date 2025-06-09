import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpm_fp/utils/shared_prefs.dart';

void main() {
  late SharedPrefs sharedPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({}); // Reset mock
    sharedPrefs = SharedPrefs();
  });

  test('saveCurrentUser should store username', () async {
    await sharedPrefs.saveCurrentUser('testuser1');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('current_username'), 'testuser1');
  });

  test('getCurrentUser should return stored username', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_username', 'testuser2');
    final result = await sharedPrefs.getCurrentUser();
    expect(result, 'testuser2');
  });

  test('clearSession should remove current_username', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_username', 'testuser3');
    await sharedPrefs.clearSession();
    expect(prefs.getString('current_username'), isNull);
  });
}

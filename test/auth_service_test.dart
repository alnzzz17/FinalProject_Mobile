import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/network/auth_service.dart';

void main() {
  late AuthService authService;

setUp(() async {
  SharedPreferences.setMockInitialValues({}); 

  await setUpTestHive();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserModelAdapter());
  }

  authService = AuthService(disableToast: true);
  await authService.init();
});

  tearDown(() async {
    await tearDownTestHive();
  });

  group('AuthService', () {
    test('Register a new user successfully', () async {
      final result = await authService.register(
        username: 'testuser',
        fullname: 'Test User',
        password: 'password123',
      );
      expect(result, isTrue);

      final box = Hive.box<UserModel>('users');
      final user = box.getAt(0);
      expect(user?.username, 'testuser');
      expect(user?.fullname, 'Test User');
    });

    test('Fail to register with duplicate username', () async {
      await authService.register(
        username: 'testuser',
        fullname: 'Test User',
        password: 'password123',
      );

      final result = await authService.register(
        username: 'testuser',
        fullname: 'Another User',
        password: 'newpass',
      );
      expect(result, isFalse);
    });

    test('Login with correct credentials', () async {
      await authService.register(
        username: 'testuser',
        fullname: 'Test User',
        password: 'password123',
      );

      final user = await authService.login(
        username: 'testuser',
        password: 'password123',
      );
      expect(user, isNotNull);
      expect(user?.fullname, 'Test User');
    });

    test('Fail login with wrong password', () async {
      await authService.register(
        username: 'testuser',
        fullname: 'Test User',
        password: 'password123',
      );

      final user = await authService.login(
        username: 'testuser',
        password: 'wrongpassword',
      );
      expect(user, isNull);
    });

    test('Update user successfully with new username and fullname', () async {
      await authService.register(
        username: 'testuser',
        fullname: 'Old Name',
        password: 'password123',
      );

      final result = await authService.updateUser(
        username: 'testuser',
        newUsername: 'updateduser',
        newFullname: 'Updated Name',
        newPassword: 'newpass123',
      );

      expect(result, isTrue);

      final user = await authService.login(
        username: 'updateduser',
        password: 'newpass123',
      );

      expect(user, isNotNull);
      expect(user?.fullname, 'Updated Name');
    });

    test('Fail update if new username is already taken', () async {
      await authService.register(
        username: 'user1',
        fullname: 'User One',
        password: 'pass1',
      );
      await authService.register(
        username: 'user2',
        fullname: 'User Two',
        password: 'pass2',
      );

      final result = await authService.updateUser(
        username: 'user1',
        newUsername: 'user2', // already exists
        newFullname: 'User One Updated',
        newPassword: 'pass3',
      );

      expect(result, isFalse);
    });
  });
}

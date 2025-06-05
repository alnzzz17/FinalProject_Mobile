import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/utils/shared_prefs.dart';

class AuthService {
  static const String _userBoxName = 'users';
  final SharedPrefs _sharedPrefs = SharedPrefs();

  Future<void> init() async {
    await Hive.openBox<UserModel>(_userBoxName);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> register({
    required String username,
    required String fullname,
    required String password,
  }) async {
    try {
      final userBox = Hive.box<UserModel>(_userBoxName);

      // Check if username already exists
      for (var i = 0; i < userBox.length; i++) {
        final user = userBox.getAt(i);
        if (user?.username == username) {
          Fluttertoast.showToast(msg: 'Username already registered');
          return false;
        }
      }

      final newUser = UserModel(
        username: username,
        fullname: fullname,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      await userBox.add(newUser);
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Registration failed: $e');
      return false;
    }
  }

  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      final userBox = Hive.box<UserModel>(_userBoxName);

      for (var i = 0; i < userBox.length; i++) {
        final user = userBox.getAt(i);
        if (user?.username == username &&
            user?.passwordHash == _hashPassword(password)) {
          // Save current user using SharedPrefs
          await _sharedPrefs.saveCurrentUser(username);
          return user;
        }
      }

      Fluttertoast.showToast(msg: 'Invalid username or password');
      return null;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Login failed: $e');
      return null;
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    final currentUsername = await _sharedPrefs.getCurrentUser();
    if (currentUsername == null) return null;

    final userBox = Hive.box<UserModel>(_userBoxName);
    for (var i = 0; i < userBox.length; i++) {
      final user = userBox.getAt(i);
      if (user?.username == currentUsername) {
        return user;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _sharedPrefs.clearSession();
  }

  Future<bool> updateUser({
    required String username,
    required String newUsername,
    required String newFullname,
    String? newPassword,
  }) async {
    try {
      final userBox = Hive.box<UserModel>(_userBoxName);

      // Find user by username
      int? userIndex;
      UserModel? userToUpdate;

      for (var i = 0; i < userBox.length; i++) {
        final user = userBox.getAt(i);
        if (user?.username == username) {
          userIndex = i;
          userToUpdate = user;
          break;
        }
      }

      if (userIndex == null || userToUpdate == null) {
        Fluttertoast.showToast(msg: 'User not found');
        return false;
      }

      // Check if new username is already taken
      if (newUsername != username) {
        for (var i = 0; i < userBox.length; i++) {
          if (i == userIndex) continue;
          final user = userBox.getAt(i);
          if (user?.username == newUsername) {
            Fluttertoast.showToast(msg: 'Username already taken');
            return false;
          }
        }
      }

      // Update user
      final updatedUser = UserModel(
        username: newUsername,
        fullname: newFullname,
        passwordHash: newPassword != null
            ? _hashPassword(newPassword)
            : userToUpdate.passwordHash,
        createdAt: userToUpdate.createdAt,
      );

      await userBox.putAt(userIndex, updatedUser);

      // Update session if username changed
      if (newUsername != username) {
        await _sharedPrefs.saveCurrentUser(newUsername);
      }

      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Update failed: $e');
      return false;
    }
  }
}

import 'package:get/get.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/network/auth_service.dart';

class UserController extends GetxController {
  final AuthService _authService = AuthService();
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Future<void> loadCurrentUser() async {
    final user = await _authService.getCurrentUserData();
    currentUser.value = user;
  }

  Future<bool> updateProfile({
    required String currentUsername,
    required String newUsername,
    required String newFullname,
    String? newPassword,
  }) async {
    final success = await _authService.updateUser(
      username: currentUsername,
      newUsername: newUsername,
      newFullname: newFullname,
      newPassword: newPassword,
    );
    if (success) {
      await loadCurrentUser();
    }
    return success;
  }
}
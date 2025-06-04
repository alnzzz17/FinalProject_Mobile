import 'package:tpm_fp/network/auth_service.dart';
import 'package:tpm_fp/models/user_model.dart';

class ProfilePresenter {
  final AuthService _authService = AuthService();

  Future<UserModel?> getCurrentUserData() async {
    return await _authService.getCurrentUserData();
  }

  Future<bool> updateProfile({
    required String currentUsername,
    required String newUsername,
    required String newFullname,
    String? newPassword,
  }) async {
    return await _authService.updateUser(
      username: currentUsername,
      newUsername: newUsername,
      newFullname: newFullname,
      newPassword: newPassword,
    );
  }
}
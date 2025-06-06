import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/presenters/profile_presenter.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({Key? key, this.onProfileUpdated}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfilePresenter _presenter = ProfilePresenter();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullnameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _showPasswordFields = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _usernameController = TextEditingController();
    _fullnameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = await _presenter.getCurrentUserData();
    setState(() {
      _currentUser = user;
      if (user != null) {
        _usernameController.text = user.username;
        _fullnameController.text = user.fullname;
      }
      _isLoading = false;
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        if (_currentUser != null) {
          _usernameController.text = _currentUser!.username;
          _fullnameController.text = _currentUser!.fullname;
        }
        _passwordController.clear();
        _confirmPasswordController.clear();
        _showPasswordFields = false;
      }
    });
  }

  void _togglePasswordFields() {
    setState(() {
      _showPasswordFields = !_showPasswordFields;
      if (!_showPasswordFields) {
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_showPasswordFields &&
          _passwordController.text != _confirmPasswordController.text) {
        Get.snackbar(
          'Error',
          'Passwords do not match',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
        return;
      }

      setState(() => _isLoading = true);
      final success = await _presenter.updateProfile(
        currentUsername: _currentUser?.username ?? '',
        newUsername: _usernameController.text,
        newFullname: _fullnameController.text,
        newPassword: _showPasswordFields ? _passwordController.text : null,
      );
      setState(() => _isLoading = false);

      if (success) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
        await _loadUserData();
        setState(() => _isEditing = false);
        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!();
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to update profile',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_screen'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        key: const Key('profile_app_bar'),
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Profile',
          key: Key('profile_title'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              key: const Key('edit_profile_button'),
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                key: const Key('profile_loading_indicator'),
                color: Colors.red,
              ),
            )
          : _currentUser == null
              ? Center(
                  child: Text(
                    'User data not available',
                    key: const Key('no_user_data_text'),
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  key: const Key('profile_scroll_view'),
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      key: const Key('profile_form_column'),
                      children: [
                        _buildProfilePicture(),
                        SizedBox(height: 20),
                        _buildUsernameField(),
                        SizedBox(height: 16),
                        _buildFullnameField(),
                        SizedBox(height: 16),
                        if (_isEditing) _buildPasswordToggle(),
                        if (_showPasswordFields && _isEditing) ...[
                          SizedBox(height: 16),
                          _buildPasswordField(),
                          SizedBox(height: 16),
                          _buildConfirmPasswordField(),
                        ],
                        SizedBox(height: 24),
                        if (_isEditing)
                          ElevatedButton(
                            key: const Key('save_profile_button'),
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                            ),
                            child: Text(
                              'Save Changes',
                              key: const Key('save_profile_button_text'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        key: const Key('profile_picture_stack'),
        children: [
          Container(
            key: const Key('profile_picture_container'),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              key: const Key('profile_avatar'),
              radius: 60,
              backgroundImage: AssetImage('assets/images/default.png'),
              backgroundColor: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      key: const Key('username_input_field'),
      controller: _usernameController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        prefixIcon: Icon(Icons.person, color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      readOnly: !_isEditing,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter username';
        }
        return null;
      },
    );
  }

  Widget _buildFullnameField() {
    return TextFormField(
      key: const Key('fullname_input_field'),
      controller: _fullnameController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Fullname',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        prefixIcon: Icon(Icons.badge, color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      readOnly: !_isEditing,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter fullname';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordToggle() {
    return Row(
      key: const Key('password_toggle_row'),
      children: [
        Checkbox(
          key: const Key('change_password_checkbox'),
          value: _showPasswordFields,
          onChanged: (value) => _togglePasswordFields(),
          activeColor: Colors.red,
          checkColor: Colors.white,
        ),
        Text(
          'Change Password',
          key: const Key('change_password_text'),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: const Key('password_input_field'),
      controller: _passwordController,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'New Password',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          key: const Key('toggle_password_visibility_button'),
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      obscureText: _obscurePassword,
      validator: _showPasswordFields
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      key: const Key('confirm_password_input_field'),
      controller: _confirmPasswordController,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: 'Confirm New Password',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          key: const Key('toggle_confirm_password_visibility_button'),
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      obscureText: true,
      validator: _showPasswordFields
          ? (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            }
          : null,
    );
  }
}
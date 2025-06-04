import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/models/user_model.dart';
import 'package:tpm_fp/presenters/profile_presenter.dart';

class ProfileScreen extends StatefulWidget {
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
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
                color: Colors.red,
              ),
            )
          : _currentUser == null
              ? Center(
                  child: Text(
                    'User data not available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
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
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                            ),
                            child: Text(
                              'Save Changes',
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
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: CircleAvatar(
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
      children: [
        Checkbox(
          value: _showPasswordFields,
          onChanged: (value) => _togglePasswordFields(),
          activeColor: Colors.red,
          checkColor: Colors.white,
        ),
        Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
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
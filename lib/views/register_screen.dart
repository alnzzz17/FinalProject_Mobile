import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tpm_fp/network/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('register-screen'),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              // Logo
              Image.asset(
                'assets/images/logo.png',
                key: const Key('register-logo'),
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                'CREATE ACCOUNT',
                key: const Key('register-title'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      key: const Key('username-field'),
                      controller: _usernameController,
                      label: 'Username',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      key: const Key('fullname-field'),
                      controller: _fullnameController,
                      label: 'Fullname',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter fullname';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      key: const Key('password-field'),
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: !_showPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      toggleVisibility: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      showPassword: _showPassword,
                    ),
                    SizedBox(height: 16),
                    _buildPasswordField(
                      key: const Key('confirm-password-field'),
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscureText: !_showConfirmPassword,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      toggleVisibility: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                      showPassword: _showConfirmPassword,
                    ),
                    SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator(
                            key: const Key('register-loading'),
                            color: Colors.red)
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const Key('register-button'),
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30)
                              ),
                              child: Text(
                                'REGISTER',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    TextButton(
                      key: const Key('login-button'),
                      onPressed: () {
                        Get.offAllNamed('/login');
                      },
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required String? Function(String?) validator,
    required VoidCallback toggleVisibility,
    required bool showPassword,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          key: const Key('password-visibility-button'),
          icon: Icon(
            showPassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggleVisibility,
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      validator: validator,
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final success = await _authService.register(
        username: _usernameController.text,
        fullname: _fullnameController.text,
        password: _passwordController.text,
      );
      setState(() => _isLoading = false);
      if (success) {
        Get.snackbar(
          'Success',
          'Account created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await Future.delayed(Duration(milliseconds: 1000));
        Get.offAllNamed('/login');
      }
    }
  }
}
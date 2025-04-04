import 'package:bitewise/auth/auth_view.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';

class AuthViewmodel extends ChangeNotifier {
  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // State variables
  bool acceptTerms = false;
  bool obscurePassword = true;
  AuthMode _mode = AuthMode.login;

  AuthMode get mode => _mode;

  AuthViewmodel({required AuthMode initialMode}) : _mode = initialMode;

  void toggleMode() {
    _mode = _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleAcceptTerms(bool? value) {
    acceptTerms = value ?? false;
    notifyListeners();
  }

  Future<void> submitForm(BuildContext context) async {
    if (mode == AuthMode.signup && !acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    try {
      if (mode == AuthMode.login) {
        await _login();
      } else {
        await _signup();
      }

      // Navigate on success
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, Routes.splashPageKey);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _login() async {
    // Implement your login logic here
    final email = emailController.text;
    final password = passwordController.text;

    // Example validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Please fill all fields');
    }

    // Call your authentication service
    // await AuthService.login(email, password);
  }

  Future<void> _signup() async {
    // Implement your signup logic here
    final email = emailController.text;
    final password = passwordController.text;
    final name = nameController.text;
    final phone = phoneController.text;

    // Example validation
    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      throw Exception('Please fill all fields');
    }

    // Call your authentication service
    // await AuthService.signup(name, email, phone, password);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

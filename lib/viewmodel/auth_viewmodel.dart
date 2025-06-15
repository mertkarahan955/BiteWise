import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:bitewise/view/auth_view.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _onboardingPreferences;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryCodeController =
      TextEditingController(text: '+90');

  // Temporary storage for form data
  String? _tempEmail;
  String? _tempPassword;
  String? _tempName;
  String? _tempPhone;
  String? _tempCountryCode;

  // State variables
  bool acceptTerms = false;
  bool obscurePassword = true;
  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;

  AuthMode get mode => _mode;
  bool get isLoading => _isLoading;

  AuthViewmodel({required AuthMode initialMode}) : _mode = initialMode;

  // Restore form data after returning from onboarding
  void _restoreFormData() {
    if (_tempEmail != null) emailController.text = _tempEmail!;
    if (_tempPassword != null) passwordController.text = _tempPassword!;
    if (_tempName != null) nameController.text = _tempName!;
    if (_tempPhone != null) phoneController.text = _tempPhone!;
    if (_tempCountryCode != null) {
      countryCodeController.text = _tempCountryCode!;
    }
  }

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

  Future<String?> submitForm(BuildContext context,
      {required bool isFormValid}) async {
    if (!isFormValid) return null;
    if (mode == AuthMode.signup && !acceptTerms) {
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (mode == AuthMode.login) {
        await _login();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, Routes.homePageKey);
        }
        return "success";
      } else {
        // Check if user has completed onboarding
        final prefs = await SharedPreferences.getInstance();
        final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
        if (_onboardingPreferences == null && !onboardingSeen) {
          if (context.mounted) {
            // Show dialog to inform user about onboarding
            final shouldProceed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Complete Onboarding First'),
                content: const Text(
                  'To provide you with the best experience, please complete the onboarding process first. This will help us personalize your experience.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: const Text(
                      'Go to Onboarding',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );

            if (shouldProceed == true && context.mounted) {
              // Navigate to onboarding and wait for result
              final result = await Navigator.pushNamed(
                context,
                Routes.onboardingPageKey,
              );

              // If we got preferences back from onboarding
              if (result is UserModel) {
                setOnboardingPreferences(result);
                // After getting preferences, proceed with signup
                await _signup();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, Routes.homePageKey);
                }
                return "success";
              }
              return null;
            }
            return null;
          }
        } else {
          // If onboarding is already completed or preferences are set
          await _signup();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, Routes.homePageKey);
          }
          return "success";
        }
      }
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _login() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Please fill all fields');
    }

    await _firebaseService.signIn(
      email: email,
      password: password,
    );
  }

  Future<void> _signup() async {
    final email = emailController.text;
    final password = passwordController.text;
    final name = nameController.text;
    final phone = phoneController.text;

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      throw Exception('Please fill all fields');
    }

    // Sign up the user
    final userCredential = await _firebaseService.signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    // If we have onboarding preferences, save them
    if (_onboardingPreferences != null) {
      await _firebaseService.saveUserPreferences(
        userId: userCredential.user!.uid,
        userModel: _onboardingPreferences!,
      );
      await _setOnboardingSeen();
    }
  }

  Future<void> _setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  Future<void> logout(BuildContext context) async {
    await _firebaseService.signOut();
    // Remove onboarding_seen from cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_seen');
    if (context.mounted) {
      Navigator.pushReplacementNamed(
        context,
        Routes.authPageKey,
        arguments: AuthMode.login,
      );
    }
  }

  // Method to set onboarding preferences
  void setOnboardingPreferences(UserModel preferences) {
    _onboardingPreferences = preferences;
    // Restore form data when returning from onboarding
    _restoreFormData();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    countryCodeController.dispose();
    super.dispose();
  }
}

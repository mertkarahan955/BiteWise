import 'package:bitewise/services/interfaces/i_firebase_service.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitewise/view/auth_view.dart';

class SplashViewmodel extends ChangeNotifier {
  final IFirebaseService _firebaseService;
  bool _isLoading = true;
  String? _error;

  SplashViewmodel({
    required IFirebaseService firebaseService,
  }) : _firebaseService = firebaseService;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> checkAuthState() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return _firebaseService.isUserLoggedIn();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error checking auth state: $e');
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('onboarding_seen', false);
        prefs.setBool('register_onboarding', false);
      });

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkUserStatus(BuildContext context) async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!context.mounted) return;

    // Check if user is logged in
    if (await checkAuthState()) {
      Navigator.pushReplacementNamed(context, Routes.homePageKey);
    } else {
      // Check onboarding status
      final prefs = await SharedPreferences.getInstance();
      final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
      if (onboardingSeen) {
        Navigator.pushReplacementNamed(context, Routes.authPageKey,
            arguments: AuthMode.signup);
      } else {
        Navigator.pushReplacementNamed(context, Routes.onboardingPageKey);
      }
    }
  }
}

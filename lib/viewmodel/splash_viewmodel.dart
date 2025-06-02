import 'package:bitewise/services/firebase_service.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitewise/view/auth_view.dart';

class SplashViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> checkUserStatus(BuildContext context) async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    // Check if user is logged in
    if (_firebaseService.isUserLoggedIn()) {
      Navigator.pushReplacementNamed(context, Routes.homePageKey);
    } else {
      // Check onboarding status
      final prefs = await SharedPreferences.getInstance();
      final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
      if (onboardingSeen) {
        Navigator.pushReplacementNamed(context, Routes.authPageKey,
            arguments: AuthMode.login);
      } else {
        Navigator.pushReplacementNamed(context, Routes.onboardingPageKey);
      }
    }
  }
}

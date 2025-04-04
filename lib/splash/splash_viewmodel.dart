import 'package:bitewise/auth/repo/auth_repository.dart';
import 'package:bitewise/utils/locator.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';

class SplashViewmodel with ChangeNotifier {
  final AuthRepository _authRepository;

  SplashViewmodel() : _authRepository = locator<AuthRepository>();

  void navigate(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);
    _openLoginPage(navigator);
  }

  void _openHomePage(NavigatorState navigator) {
    navigator.pushReplacementNamed(Routes.homePageKey);
  }

  void _openLoginPage(NavigatorState navigator) {
    navigator.pushReplacementNamed(Routes.onboardingPageKey);
  }
}

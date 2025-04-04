import 'package:bitewise/auth/auth_view.dart';
import 'package:bitewise/auth/auth_viewmodel.dart';
import 'package:bitewise/onboarding/onboarding_view.dart';
import 'package:bitewise/onboarding/onboarding_viewmodel.dart';
import 'package:bitewise/splash/splash_view.dart';
import 'package:bitewise/splash/splash_viewmodel.dart';
import 'package:bitewise/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Routes {
  static const String splashPageKey = '/';
  static const String onboardingPageKey = '/onboarding';
  static const String authPageKey = '/auth';
  static const String homePageKey = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashPageKey:
        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) => SplashViewmodel(),
            child: const SplashView(),
          ),
        );
      case onboardingPageKey:
        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) => OnboardingViewmodel(),
            child: const OnboardingView(),
          ),
        );
      case authPageKey:
        // Get the initial mode from arguments (defaults to login)
        final initialMode = settings.arguments as AuthMode? ?? AuthMode.signup;
        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) => locator<AuthViewmodel>(param1: initialMode),
            child: AuthView(),
          ),
        );
      default:
        return _buildRoute(
          settings,
          const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildRoute(RouteSettings settings, Widget page) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

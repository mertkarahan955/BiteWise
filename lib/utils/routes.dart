import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/view/auth_view.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:bitewise/view/onboarding_view.dart';
import 'package:bitewise/viewmodel/onboarding_viewmodel.dart';
import 'package:bitewise/view/splash_view.dart';
import 'package:bitewise/viewmodel/splash_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/view/profile_view.dart';
import 'package:bitewise/view/layout/main_layout.dart';
import 'package:bitewise/utils/locator.dart';

class Routes {
  static const String splashPageKey = '/';
  static const String onboardingPageKey = '/onboarding';
  static const String authPageKey = '/auth';
  static const String homePageKey = '/home';
  static const String profilePageKey = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashPageKey:
        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) => locator<SplashViewmodel>(),
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
        final args = settings.arguments;
        debugPrint('Auth page route arguments: $args');

        AuthMode mode;
        UserModel? preferences;

        if (args is AuthMode) {
          mode = args;
        } else if (args is Map<String, dynamic>) {
          mode = args['mode'] as AuthMode;
          preferences = args['preferences'] as UserModel?;
        } else {
          mode = AuthMode.login;
        }

        debugPrint('Auth mode: $mode');
        if (preferences != null) {
          debugPrint('Preferences: ${preferences.toString()}');
        }

        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) {
              final viewModel = locator<AuthViewmodel>();
              if (preferences != null) {
                viewModel.setOnboardingPreferences(preferences);
              }
              return viewModel;
            },
            child: AuthView(initialMode: mode),
          ),
        );
      case profilePageKey:
        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) => locator<ProfileViewmodel>(),
            child: const ProfileView(),
          ),
        );
      case homePageKey:
        return _buildRoute(
          settings,
          const MainLayout(),
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

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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

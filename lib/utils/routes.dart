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
        final args = settings.arguments;
        AuthMode initialMode;
        UserModel? preferences;

        if (args is Map<String, dynamic>) {
          initialMode = args['mode'] as AuthMode? ?? AuthMode.login;
          preferences = args['preferences'] as UserModel?;
        } else {
          initialMode = args as AuthMode? ?? AuthMode.login;
        }

        return _buildRoute(
          settings,
          ChangeNotifierProvider(
            create: (context) {
              final viewModel = AuthViewmodel(initialMode: initialMode);
              if (preferences != null) {
                viewModel.setOnboardingPreferences(preferences);
              }
              return viewModel;
            },
            child: const AuthView(),
          ),
        );
      case profilePageKey:
        return _buildRoute(
          settings,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => ProfileViewmodel()..loadUserProfile(),
              ),
            ],
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

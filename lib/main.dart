import 'package:bitewise/firebase_options.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:bitewise/utils/locator.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/viewmodel/home_viewmodel.dart';
import 'package:bitewise/viewmodel/splash_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file before Firebase initialization
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthViewmodel>()),
        ChangeNotifierProvider(create: (_) => locator<ProfileViewmodel>()),
        ChangeNotifierProvider(create: (_) => locator<MealsViewmodel>()),
        ChangeNotifierProvider(create: (_) => locator<HomeViewmodel>()),
        ChangeNotifierProvider(create: (_) => locator<SplashViewmodel>()),
        Provider<FirebaseService>(
          create: (_) => locator<FirebaseService>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        onGenerateTitle: (context) => "BiteWise",
        initialRoute: Routes.splashPageKey,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}

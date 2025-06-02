import 'package:bitewise/firebase_options.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:bitewise/utils/locator.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:bitewise/view/auth_view.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(
          create: (_) => AuthViewmodel(initialMode: AuthMode.login),
        ),
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
      ],
      child: MaterialApp(
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

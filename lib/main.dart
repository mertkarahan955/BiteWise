import 'package:bitewise/utils/locator.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      onGenerateTitle: (context) => "BiteWise",
      initialRoute: Routes.splashPageKey,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

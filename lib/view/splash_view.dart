import 'package:bitewise/viewmodel/splash_viewmodel.dart';
import 'package:bitewise/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Call the check after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashViewmodel>().checkUserStatus(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageTransformers(ImageConstants.logo).svgLogo,
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

import 'package:bitewise/splash/splash_viewmodel.dart';
import 'package:bitewise/utils/image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashView extends StatelessWidget {
  final Duration _splashDuration = const Duration(milliseconds: 1000);
  final bool waitForDuration;
  const SplashView({super.key, this.waitForDuration = true});
  @override
  Widget build(BuildContext context) {
    _navigate(context);
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: ImageTransformers(ImageConstants.logo).svgLogo,
    );
  }

  void _navigate(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (waitForDuration) {
        Future.delayed(_splashDuration).then((_) {
          if (context.mounted) {
            _redirect(context);
          }
        });
      } else {
        _redirect(context);
      }
    });
  }

  void _redirect(BuildContext context) {
    SplashViewmodel viewModel = Provider.of<SplashViewmodel>(
      context,
      listen: false,
    );
    viewModel.navigate(context);
  }
}

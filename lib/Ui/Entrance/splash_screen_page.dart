import 'package:flutter/material.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/ViewModels/splash_screen_viewmodel.dart';

class SplashScreenPage extends StatelessWidget {
  static const routeName = "/";

  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => SplashScreenViewModel().init(context));

    final screenSize = MediaQuery.of(context).size;
    final refSize = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    final size = refSize / 3;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: screenSize.height,
        width: screenSize.width,
        alignment: Alignment.center,
        color: PeanutTheme.primaryColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/entrance_background.jpg",
              width: size,
              height: size,
            ),
            const Text(
              "PEANUT",
              style: TextStyle(fontWeight: FontWeight.bold, color: PeanutTheme.white),
            ),
          ],
        ),
      ),
    );
  }
}

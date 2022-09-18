import 'package:flutter/material.dart';
import 'package:peanut/App/theme.dart';

class SplashScreenPage extends StatelessWidget {
  static const routeName = "/~";

  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final refSize = screenSize.width < screenSize.height ? screenSize.width : screenSize.height;
    final size = refSize / 3;

    return Container(
      height: screenSize.height,
      width: screenSize.width,
      alignment: Alignment.center,
      color: PeanutTheme.white,
      // child: Image.asset(
      //   "assets/splashscreen.png",
      //   width: size,
      //   height: size,
      // ),
    );
  }
}

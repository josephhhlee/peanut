import 'package:flutter/material.dart';

class PeanutTheme {
  static const MaterialColor swatchColors = Colors.orange;
  static const Color primaryColor = Color.fromARGB(1, 244, 187, 68);
  static const Color secondaryColor = Color.fromARGB(1, 243, 243, 62);
  static const Color backGroundColor = Color(0xFFF3F3F3);
  static const Color transparent = Colors.transparent;
  static const Color greyDivider = Color(0xFFE0E0E0);
  static const Color black = Colors.black;
  static const Color almostBlack = Color(0xFF424242);
  static const Color white = Colors.white;
  static const Color errorColor = Color.fromARGB(1, 255, 51, 51);

  static const TextTheme defaultTextStyle = TextTheme();

  static ThemeData defaultTheme() => ThemeData(
        primarySwatch: swatchColors,
        primaryColor: primaryColor,
        backgroundColor: backGroundColor,
        textTheme: defaultTextStyle,
      );

  static Widget background(Widget child) => Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/entrance_background.jpg"),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.lighten),
          ),
        ),
        child: child,
      );
}

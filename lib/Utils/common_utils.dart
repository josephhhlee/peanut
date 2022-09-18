import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peanut/App/theme.dart';

class CommonUtils {
  static void toast(
    BuildContext context,
    String msg, {
    gravity = ToastGravity.BOTTOM,
    int duration = 3,
    double fontSize = 16,
    Color backgroundColor = PeanutTheme.primaryColor,
    Color textColor = PeanutTheme.white,
  }) {
    if (msg.isEmpty) return;

    var fToast = FToast();
    if (fToast.context == null || fToast.context != context) {
      fToast.init(context);
    } else {
      fToast.removeQueuedCustomToasts();
    }

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(5)),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: gravity,
      toastDuration: Duration(seconds: duration),
    );
  }
}

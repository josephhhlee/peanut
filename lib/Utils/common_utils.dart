import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/user_model.dart';

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

  static Widget buildUserImage({required BuildContext context, required NutUser user, double size = 65, bool allowGesture = true}) {
    final color = Color(user.uid.hashCode * 0xffffffff).withOpacity(1).withAlpha(255);
    Widget backGround({required Widget child}) => ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.4),
          child: Container(
            height: size,
            width: size,
            color: color,
            alignment: Alignment.center,
            child: child,
          ),
        );

    if (user.displayPhoto != null && user.displayPhoto!.isNotEmpty) {
      final String imageUrl = user.displayPhoto!;
      return backGround(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
        ),
      );
    }

    var abbrName = user.displayName.split(" ").map((e) => e[0]).join().toUpperCase();
    abbrName = abbrName.substring(0, 3 > abbrName.length ? abbrName.length : 3);

    return backGround(
      child: Text(
        abbrName,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: TextStyle(fontWeight: FontWeight.bold, color: PeanutTheme.white, fontSize: size * 0.3),
      ),
    );
  }
}

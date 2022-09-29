import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:provider/provider.dart';

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

  static peanutCurrency({String? value, double iconSize = 55, double textSize = 18, Color color = PeanutTheme.almostBlack}) => Row(children: [
        Text(
          value ?? "0",
          style: TextStyle(color: color, fontSize: textSize, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 2),
        Image.asset(
          "assets/currency.png",
          fit: BoxFit.scaleDown,
          scale: iconSize,
        ),
      ]);

  static currentUserPeanutCurrency({double iconSize = 55, double textSize = 18, Color color = PeanutTheme.almostBlack}) => Consumer<DataStore>(
        builder: (_, value, __) => value.currentUserPeanutCurrency == null
            ? const SizedBox.shrink()
            : peanutCurrency(
                value: value.currentUserPeanutCurrency.toString(),
                color: color,
                textSize: textSize,
                iconSize: iconSize,
              ),
      );

  static Widget loadingIndicator({double size = 30}) => Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: PeanutTheme.primaryColor,
          secondRingColor: PeanutTheme.almostBlack,
          thirdRingColor: PeanutTheme.secondaryColor,
          size: size,
        ),
      );

  static String getDateTimeAgo(int timestamp) {
    var now = DateTime.now();
    var inputDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(inputDate);

    if ((now.year == inputDate.year && now.month == inputDate.month) || diff.inDays < 31) {
      if (diff.inSeconds < 60) {
        return "Just now";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes} ${diff.inMinutes == 1 ? "min" : "mins"} ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours} ${diff.inHours == 1 ? "hr" : "hrs"} ago";
      } else if (diff.inDays < 7) {
        return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
      } else {
        int weeks = diff.inDays ~/ 7;
        return "$weeks ${weeks == 1 ? "week" : "weeks"} ago";
      }
    } else if (now.year == inputDate.year || diff.inDays < 365) {
      double avgDaysInAMonth = 30.437;
      num months = now.year == inputDate.year ? now.month - inputDate.month : diff.inDays / avgDaysInAMonth;
      return "$months ${months == 1 ? "month" : "months"} ago";
    } else {
      int years = now.year - inputDate.year;
      return "$years ${years == 1 ? "year" : "years"} ago";
    }
  }
}

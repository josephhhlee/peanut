import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  static Future<Marker> Function(Cluster) get markerBuilder => (cluster) async {
        Future<BitmapDescriptor> getClusterBitmap(int size, {String? text}) async {
          final PictureRecorder pictureRecorder = PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          final Paint paint1 = Paint()..color = PeanutTheme.almostBlack;

          canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

          if (text != null) {
            TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
            painter.text = TextSpan(
              text: text,
              style: TextStyle(fontSize: size / 3, color: Colors.white, fontWeight: FontWeight.normal),
            );
            painter.layout();
            painter.paint(
              canvas,
              Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
            );
          }

          final img = await pictureRecorder.endRecording().toImage(size, size);
          final data = await img.toByteData(format: ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
        }

        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {},
          icon: await getClusterBitmap(cluster.isMultiple ? 125 : 75, text: cluster.isMultiple ? cluster.count.toString() : "1"),
        );
      };
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';

class PeanutMapViewModel {
  ValueNotifier<List<Quest>?> questList = ValueNotifier(null);

  Future<Marker> Function(Cluster<Quest>) get markerBuilder => (cluster) async {
        Future<BitmapDescriptor> getClusterBitmap(int size, {String? text}) async {
          final PictureRecorder pictureRecorder = PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          final Paint paint1 = Paint()..color = PeanutTheme.almostBlack;

          canvas.drawCircle(Offset(size / 2, size / 2), size / 3, paint1);

          if (text != null) {
            TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
            painter.text = TextSpan(
              text: text,
              style: TextStyle(fontSize: size / 2.5, color: Colors.white, fontWeight: FontWeight.normal),
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
          onTap: () => questList.value = cluster.items.toList(),
          icon: await getClusterBitmap(cluster.isMultiple ? 125 : 75, text: cluster.isMultiple ? cluster.count.toString() : "1"),
        );
      };
}

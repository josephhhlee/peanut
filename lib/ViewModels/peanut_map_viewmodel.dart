import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';

class PeanutMapViewModel {
  ClusterManager<Quest>? manager;
  ValueNotifier<List<Quest>?> questList = ValueNotifier(null);
  String? selectedMarker;

  void clearSelectedMarker() {
    questList.value = null;
    selectedMarker = null;
    manager?.updateMap();
  }

  Future<Marker> Function(Cluster<Quest>) get markerBuilder => (cluster) async {
        Future<BitmapDescriptor> getClusterBitmap(int size, {String? text}) async {
          final PictureRecorder pictureRecorder = PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          final Paint paint1 = Paint()..color = PeanutTheme.almostBlack;
          final Paint paint2 = Paint()..color = PeanutTheme.white;
          final Paint paint3 = Paint()..color = cluster.getId() == selectedMarker ? PeanutTheme.secondaryColor : PeanutTheme.darkOrange;

          canvas.drawCircle(Offset(size / 2, size / 2), size / 3, paint1);
          canvas.drawCircle(Offset(size / 2, size / 2), size / 3.2, paint2);
          canvas.drawCircle(Offset(size / 2, size / 2), size / 3.8, paint3);

          if (text != null) {
            TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
            painter.text = TextSpan(
              text: text,
              style: TextStyle(fontSize: size / 2.5, color: cluster.getId() == selectedMarker ? PeanutTheme.almostBlack : PeanutTheme.white, fontWeight: FontWeight.normal),
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
          onTap: () {
            questList.value = cluster.items.toList()..sort((a, b) => b.createdOn.compareTo(a.createdOn));
            selectedMarker = cluster.getId();
            manager?.updateMap();
          },
          icon: await getClusterBitmap(cluster.isMultiple ? 125 : 75, text: cluster.isMultiple ? cluster.count.toString() : "1"),
        );
      };
}

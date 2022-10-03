import 'dart:ui';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Services/firestore_service.dart';

class PeanutMapViewModel {
  GoogleMapController? mapController;
  ClusterManager<Quest>? manager;

  ValueNotifier<List<Quest>?> subQuestList = ValueNotifier(null);
  final List<Quest> fullQuestList = [];

  String? _selectedMarker;
  String? _geohash;

  Set<Marker> markers = {};

  bool initMarkers = false;

  late final void Function() _refresh;

  void init(Function() refresh) {
    _refresh = refresh;
    DataStore().addLocationListener(_fetchUserLocation);
  }

  void dispose() {
    mapController?.dispose();
    mapController = null;
  }

  Future<void> _fetchUserLocation(LocationData? location) async {
    final lat = location?.latitude;
    final lng = location?.longitude;
    if (lat == null || lng == null) return;

    mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));

    final geohash = GeoHasher().encode(lng, lat, precision: Configs.geohashPrecision);
    if (_geohash != geohash) await _fetchQuests(geohash);
  }

  Future<void> _fetchQuests(String geohash) async {
    _geohash = geohash;
    final surroundings = [_geohash!, ...GeoHasher().neighbors(_geohash!).keys];
    FirestoreService.questsCol.where("geohash", whereIn: surroundings).where("taker", isEqualTo: null).snapshots().listen((snapshot) {
      fullQuestList.clear();
      fullQuestList.addAll(snapshot.docs.map((e) => Quest.fromSnapshot(e)));
      fullQuestList.removeWhere((element) => element.taker != null);
      if (manager != null) {
        manager?.setItems(fullQuestList);
      } else {
        manager = ClusterManager<Quest>(fullQuestList, _updateMarkers, markerBuilder: _markerBuilder);
        manager?.setMapId(mapController!.mapId);
      }
      _refresh();
    });
  }

  void _updateMarkers(Set<Marker> markers) {
    initMarkers = true;
    this.markers = markers;
    _refresh();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    controller.setMapStyle(DataStore().mapTheme);
    if (manager != null) manager?.setMapId(controller.mapId);
    _refresh();
  }

  void clearSelectedMarker() {
    subQuestList.value = null;
    _selectedMarker = null;
    manager?.updateMap();
  }

  Future<Marker> Function(Cluster<Quest>) get _markerBuilder => (cluster) async {
        Future<BitmapDescriptor> getClusterBitmap(double size, {String? text}) async {
          final PictureRecorder pictureRecorder = PictureRecorder();
          final Canvas canvas = Canvas(pictureRecorder);
          final Paint paint1 = Paint()..color = PeanutTheme.almostBlack;
          final Paint paint2 = Paint()..color = PeanutTheme.white;
          final Paint paint3 = Paint()..color = cluster.getId() == _selectedMarker ? PeanutTheme.secondaryColor : PeanutTheme.darkOrange;

          canvas.drawCircle(Offset(size / 2, size / 2), size / 3, paint1);
          canvas.drawCircle(Offset(size / 2, size / 2), size / 3.2, paint2);
          canvas.drawCircle(Offset(size / 2, size / 2), size / 3.8, paint3);

          if (text != null) {
            TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
            painter.text = TextSpan(
              text: text,
              style: TextStyle(fontSize: size / 2.5, color: cluster.getId() == _selectedMarker ? PeanutTheme.almostBlack : PeanutTheme.white, fontWeight: FontWeight.normal),
            );
            painter.layout();
            painter.paint(
              canvas,
              Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
            );
          }

          final img = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
          final data = await img.toByteData(format: ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
        }

        final screenWidth = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
        var markerSize = (screenWidth * 0.2);
        markerSize = cluster.isMultiple ? markerSize * 1.25 : markerSize;

        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            subQuestList.value = cluster.items.toList()..sort((a, b) => b.createdOn.compareTo(a.createdOn));
            _selectedMarker = cluster.getId();
            manager?.updateMap();
          },
          icon: await getClusterBitmap(markerSize, text: cluster.count.toString()),
        );
      };
}

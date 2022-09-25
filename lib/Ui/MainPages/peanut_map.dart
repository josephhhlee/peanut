import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Utils/common_utils.dart';
import 'package:peanut/Utils/loading_utils.dart';

class PeanutMap extends StatefulWidget {
  const PeanutMap({super.key});

  @override
  State<PeanutMap> createState() => _PeanutMapState();
}

class _PeanutMapState extends State<PeanutMap> {
  GoogleMapController? _controller;
  ClusterManager<Quest>? _manager;
  Set<Marker> _markers = {};
  String? _geohash;
  bool _initMarkers = false;

  @override
  void initState() {
    DataStore().addLocationListener(_fetchUserLocation);
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> _fetchUserLocation(LocationData? location) async {
    final lat = location?.latitude;
    final lng = location?.longitude;
    if (lat == null || lng == null) return;

    _controller?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));

    final geohash = GeoHasher().encode(lng, lat, precision: Configs.geohashPrecision);
    if (_geohash != geohash) await _fetchQuests(geohash);
  }

  Future<void> _fetchQuests(String geohash) async {
    _geohash = geohash;
    final surroundings = [_geohash!, ...GeoHasher().neighbors(_geohash!).keys];
    FirestoreService.questsCol.where("geohash", whereIn: surroundings).snapshots().listen((snapshot) {
      final quests = snapshot.docs.map((e) => Quest.fromSnapshot(e));
      if (_manager != null) {
        _manager?.setItems(quests.toList());
      } else {
        _manager = ClusterManager<Quest>(quests, _updateMarkers, markerBuilder: CommonUtils.markerBuilder);
        _manager?.setMapId(_controller!.mapId);
      }
    });
  }

  void _updateMarkers(Set<Marker> markers) => setState(() {
        _initMarkers = true;
        _markers = markers;
      });

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    controller.setMapStyle(DataStore().mapTheme);
    if (_manager != null) _manager?.setMapId(controller.mapId);
  }

  @override
  Widget build(BuildContext context) {
    final location = DataStore().locationData;
    final lat = location?.latitude;
    final lng = location?.longitude;

    return Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(lat!, lng!), zoom: Configs.mapZoomLevel),
          markers: _markers,
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: _onMapCreated,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
        if (!_initMarkers) Loading.loadingIndicator(),
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';

class PeanutMap extends StatefulWidget {
  const PeanutMap({super.key});

  @override
  State<PeanutMap> createState() => _PeanutMapState();
}

class _PeanutMapState extends State<PeanutMap> {
  GoogleMapController? _controller;

  @override
  void initState() {
    DataStore().addLocationListener((location) {
      final lat = location?.latitude;
      final lng = location?.longitude;
      _controller?.animateCamera(CameraUpdate.newLatLng(LatLng(lat!, lng!)));
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    controller.setMapStyle(DataStore().mapTheme);
  }

  @override
  Widget build(BuildContext context) {
    final location = DataStore().locationData;
    final lat = location?.latitude;
    final lng = location?.longitude;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: LatLng(lat!, lng!), zoom: Configs.mapZoomLevel),
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
      ],
    );
  }
}

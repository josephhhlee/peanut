import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/data_store.dart';

class PeanutMap extends StatefulWidget {
  const PeanutMap({super.key});

  @override
  State<PeanutMap> createState() => _PeanutMapState();
}

class _PeanutMapState extends State<PeanutMap> {
  GoogleMapController? controller;

  @override
  void initState() {
    DataStore().addLocationListener((location) {
      final lat = location?.latitude;
      final lng = location?.longitude;
      controller?.animateCamera(CameraUpdate.newLatLng(LatLng(lat!, lng!)));
    });
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = DataStore().locationData;
    final lat = location?.latitude;
    final lng = location?.longitude;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            this.controller = controller;
            controller.setMapStyle(DataStore().mapTheme);
          },
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          initialCameraPosition: CameraPosition(target: LatLng(lat!, lng!), zoom: 15),
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: false,
          zoomControlsEnabled: false,
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

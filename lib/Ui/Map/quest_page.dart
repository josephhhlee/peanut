import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:peanut/Utils/common_utils.dart';

class QuestPage extends StatefulWidget {
  static const routeName = "/quest-page";

  final dynamic args;

  const QuestPage(this.args, {super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  late GoogleMapController? _mapController;
  late final NutUser user;
  late final Quest quest;
  late final String createdOn;

  @override
  void initState() {
    user = widget.args[0];
    quest = widget.args[1];
    createdOn = DateFormat.yMMMMEEEEd().format(DateTime.fromMillisecondsSinceEpoch(quest.createdOn!));
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) => setState(() {
        _mapController = controller;
        controller.setMapStyle(DataStore().mapTheme);
      });

  void _onBack() => Navigation.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _floatingBtn(),
      appBar: AppBar(
        elevation: 0,
        title: Text("${user.displayName}'s Quest"),
        leading: BackButton(onPressed: _onBack),
        actions: [
          IconButton(
            onPressed: () => false,
            icon: const Icon(Icons.share),
            tooltip: "Share",
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _floatingBtn() => FloatingActionButton.extended(
        heroTag: "FAB",
        onPressed: () => false,
        label: const Text("Take Quest"),
      );

  Widget _body() => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _created(),
            const SizedBox(height: 20),
            _title(),
            const SizedBox(height: 20),
            _mapContainer(),
            const SizedBox(height: 20),
            _reward(),
            const SizedBox(height: 20),
            _objective(),
            const SizedBox(height: 75),
          ],
        ),
      );

  Widget _created() => Text(
        createdOn,
        style: const TextStyle(color: PeanutTheme.grey, fontWeight: FontWeight.bold),
      );

  Widget _title() => Text(
        quest.title!,
        style: const TextStyle(color: PeanutTheme.almostBlack, fontSize: 24, fontWeight: FontWeight.bold),
      );

  Widget _mapContainer() => ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AspectRatio(
            aspectRatio: 4 / 3.5,
            child: Stack(
              children: [
                _map(),
                Positioned(
                  bottom: 0,
                  child: _address(),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _map() => GoogleMap(
        markers: {
          Marker(
            markerId: const MarkerId("destination"),
            position: LatLng(quest.mapModel!.lat, quest.mapModel!.lng),
            icon: BitmapDescriptor.defaultMarker,
          )
        },
        initialCameraPosition: CameraPosition(target: LatLng(quest.mapModel!.lat, quest.mapModel!.lng), zoom: Configs.mapZoomLevel + 1),
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: _onMapCreated,
      );

  Widget _address() => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        color: PeanutTheme.backGroundColor,
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: PeanutTheme.almostBlack, size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                quest.mapModel!.addr,
                style: const TextStyle(color: PeanutTheme.almostBlack),
              ),
            ),
          ],
        ),
      );

  Widget _reward() => Row(
        children: [
          const Text(
            "Rewards : ",
            style: TextStyle(color: PeanutTheme.almostBlack, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          CommonUtils.peanutCurrency(value: quest.rewards.toString()),
        ],
      );

  Widget _objective() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Objective",
            style: TextStyle(color: PeanutTheme.almostBlack, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(quest.description!),
        ],
      );
}

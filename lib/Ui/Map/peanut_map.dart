import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Ui/General/quest_page.dart';
import 'package:peanut/Utils/common_utils.dart';
import 'package:peanut/ViewModels/peanut_map_viewmodel.dart';

class PeanutMap extends StatefulWidget {
  const PeanutMap({super.key});

  @override
  State<PeanutMap> createState() => _PeanutMapState();
}

class _PeanutMapState extends State<PeanutMap> {
  final _viewModel = PeanutMapViewModel();
  GoogleMapController? _controller;
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
    FirestoreService.questsCol.where("geohash", whereIn: surroundings).where("taker", isEqualTo: null).snapshots().listen((snapshot) {
      final quests = snapshot.docs.map((e) => Quest.fromSnapshot(e)).toList();
      quests.removeWhere((element) => element.taker != null);
      if (_viewModel.manager != null) {
        _viewModel.manager?.setItems(quests);
      } else {
        _viewModel.manager = ClusterManager<Quest>(quests, _updateMarkers, markerBuilder: _viewModel.markerBuilder);
        _viewModel.manager?.setMapId(_controller!.mapId);
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
    if (_viewModel.manager != null) _viewModel.manager?.setMapId(controller.mapId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: true,
      portalFollower: _overLay(),
      anchor: const Aligned(
        target: Alignment.bottomCenter,
        follower: Alignment.bottomCenter,
        offset: Offset(0, -100),
      ),
      child: _body(),
    );
  }

  Widget _overLay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9, maxHeight: MediaQuery.of(context).size.height * 0.4),
        color: PeanutTheme.backGroundColor,
        child: ValueListenableBuilder(
            valueListenable: _viewModel.questList,
            builder: (_, value, __) => value == null
                ? const SizedBox.shrink()
                : ListView.builder(
                    key: Key(value.map((e) => e.toJson()).toString()),
                    padding: const EdgeInsets.all(0),
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: value.length,
                    itemBuilder: (context, index) => _questCard(value[index]),
                  )),
      ),
    );
  }

  Widget _questCard(Quest quest) => CachedUserData(
        key: Key(quest.id),
        uid: quest.creator,
        builder: (user) => Material(
          child: InkWell(
            highlightColor: PeanutTheme.primaryColor.withOpacity(0.5),
            onTap: () => user == null ? false : Navigation.push(context, QuestPage.routeName, args: [user, quest]),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: PeanutTheme.greyDivider))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonUtils.userImage(context: context, user: user, size: 65),
                  const SizedBox(width: 15),
                  Flexible(fit: FlexFit.tight, child: _questDetails(quest, user)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _questDetails(Quest quest, NutUser? user) {
    Widget name() => Text(
          user?.displayName ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, color: PeanutTheme.darkOrange),
        );

    Widget title() => Text(
          quest.title!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

    Widget address() => Row(
          children: [
            const Icon(Icons.location_on_rounded, color: PeanutTheme.almostBlack, size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                quest.mapModel!.addr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: PeanutTheme.grey),
              ),
            ),
          ],
        );

    Widget distance() => Text(
          CommonUtils.getDistance(quest.mapModel!.lat, quest.mapModel!.lng),
          style: const TextStyle(color: PeanutTheme.grey),
        );

    Widget reward() => Row(
          children: [
            const Text(
              "Rewards",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: CommonUtils.peanutCurrency(
                value: quest.rewards.toString(),
                color: PeanutTheme.primaryColor,
                textSize: 14,
                iconSize: 70,
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        name(),
        title(),
        const SizedBox(height: 15),
        address(),
        distance(),
        const SizedBox(height: 15),
        reward(),
      ],
    );
  }

  Widget _body() => Stack(
        alignment: Alignment.center,
        children: [
          _map(),
          if (!_initMarkers) CommonUtils.loadingIndicator(),
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: PeanutTheme.almostBlack.withOpacity(0.7),
              ),
              child: CommonUtils.currentUserPeanutCurrency(color: PeanutTheme.white),
            ),
          ),
        ],
      );

  Widget _map() {
    final location = DataStore().locationData;
    final lat = location?.latitude;
    final lng = location?.longitude;

    return GoogleMap(
      padding: _controller == null ? EdgeInsets.zero : const EdgeInsets.only(top: 100),
      initialCameraPosition: CameraPosition(target: LatLng(lat!, lng!), zoom: Configs.mapZoomLevel),
      markers: _markers,
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      zoomGesturesEnabled: false,
      zoomControlsEnabled: false,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      buildingsEnabled: false,
      indoorViewEnabled: false,
      liteModeEnabled: false,
      mapToolbarEnabled: false,
      trafficEnabled: false,
      onTap: (_) => _viewModel.clearSelectedMarker(),
      onMapCreated: _onMapCreated,
      onCameraMove: _viewModel.manager?.onCameraMove,
      onCameraIdle: _viewModel.manager?.updateMap,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }
}

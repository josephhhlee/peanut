import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Models/quest_model.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Utils/common_utils.dart';
import 'dart:developer';

class QuestPage extends StatefulWidget {
  static const routeName = "/quest-page";

  final dynamic args;

  const QuestPage(this.args, {super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  late GoogleMapController? _mapController;
  late final NutUser _user;
  late final Quest _quest;

  bool _buttonPressed = false;

  @override
  void initState() {
    _user = widget.args[0];
    _quest = widget.args[1];
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

  Future<void> _onTakeQuest() async {
    Future<int> calculateRemainingPeanuts() async {
      final value = await DataStore().currentUser!.getPeanutCurrency();
      final remainingPeanuts = value - Configs.questDepositCost;
      return remainingPeanuts;
    }

    void onError(String msg) {
      context.loaderOverlay.hide();
      CommonUtils.toast(context, msg, backgroundColor: PeanutTheme.errorColor);
      setState(() => _buttonPressed = false);
    }

    if (_buttonPressed) return;
    setState(() => _buttonPressed = true);

    context.loaderOverlay.show();
    await _quest.questIsTaken().then((taken) async {
      if (!taken) {
        await calculateRemainingPeanuts().then((reamining) async {
          if (reamining >= 0) {
            await FirestoreService.runTransaction((transaction) async {
              final currentUser = DataStore().currentUser!;
              _quest.assignTaker(currentUser.uid);
              await _quest.update(transaction);
              await currentUser.updatePeanutCurrency(reamining, transaction: transaction);
            }).onError((error, _) {
              log(error.toString());
              onError("An error has occurred, please try again later.");
            }).then((_) async {
              context.loaderOverlay.hide();
              CommonUtils.toast(context, "Quest has been added to your Quest List");
              await showOkAlertDialog(
                context: context,
                title: "Note",
                message: "Deposit amount of ${Configs.questDepositCost} Peanut(s) will be returned to you upon quest completion.",
              ).then((_) => Navigation.pop(context));
            });
          } else {
            onError("Insufficient Peanut(s) to take quest.");
          }
        });
      } else {
        onError("Quest is taken and no longer available.");
      }
    });
  }

  void _onBack() => Navigation.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _floatingBtn(),
      backgroundColor: PeanutTheme.backGroundColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _body(),
      ),
    );
  }

  Widget _floatingBtn() => _user.uid == DataStore().currentUser!.uid || _quest.taker != null
      ? const SizedBox.shrink()
      : FloatingActionButton.extended(
          heroTag: "FAB",
          onPressed: _onTakeQuest,
          label: Row(
            children: [
              const Text("Take Quest"),
              const SizedBox(width: 10),
              const Text("(-"),
              CommonUtils.peanutCurrency(value: Configs.questDepositCost.toString()),
              const Text(" Deposit)"),
            ],
          ),
        );

  Widget _body() => Column(
        children: [
          _mapContainer(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                _header(),
                const SizedBox(height: 10),
                _reward(),
                const SizedBox(height: 20),
                _objective(),
                SizedBox(height: _user.uid == DataStore().currentUser!.uid ? 20 : 75),
              ],
            ),
          ),
        ],
      );

  Widget _header() => Row(
        children: [
          Expanded(child: _title()),
          CommonUtils.buildUserImage(context: context, user: _user),
        ],
      );

  Widget _title() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _quest.title!,
            style: const TextStyle(color: PeanutTheme.almostBlack, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  "By ${_user.uid == DataStore().currentUser!.uid ? "Me" : _user.displayName}",
                  style: const TextStyle(color: PeanutTheme.grey, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.access_time_rounded,
                color: PeanutTheme.grey,
                size: 15,
              ),
              Text(
                CommonUtils.getDateTimeAgo(_quest.createdOn!),
                style: const TextStyle(color: PeanutTheme.grey),
              ),
            ],
          ),
        ],
      );

  Widget _mapContainer() => ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          child: Stack(
            children: [
              _map(),
              Positioned(bottom: 0, child: _address()),
              Positioned(top: 50, left: 20, child: _backBtn()),
              Positioned(top: 50, right: 20, child: _shareBtn()),
            ],
          ),
        ),
      );

  Widget _map() => GoogleMap(
        markers: {
          Marker(
            markerId: const MarkerId("destination"),
            position: LatLng(_quest.mapModel!.lat, _quest.mapModel!.lng),
            icon: BitmapDescriptor.defaultMarker,
          )
        },
        initialCameraPosition: CameraPosition(target: LatLng(_quest.mapModel!.lat, _quest.mapModel!.lng), zoom: Configs.mapZoomLevel + 1),
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
        decoration: BoxDecoration(
          color: PeanutTheme.almostBlack,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: PeanutTheme.primaryColor, size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _quest.mapModel!.addr,
                style: const TextStyle(color: PeanutTheme.white),
              ),
            ),
          ],
        ),
      );

  Widget _backBtn() => Container(
        decoration: BoxDecoration(
          color: PeanutTheme.almostBlack.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: BackButton(
          onPressed: _onBack,
          color: PeanutTheme.white,
        ),
      );

  Widget _shareBtn() => Container(
        decoration: BoxDecoration(
          color: PeanutTheme.almostBlack.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: IconButton(
          tooltip: "Share",
          icon: const Icon(Icons.share, color: PeanutTheme.secondaryColor),
          onPressed: () => false,
        ),
      );

  Widget _reward() => Row(
        children: [
          const Text(
            "Rewards : ",
            style: TextStyle(color: PeanutTheme.almostBlack, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: PeanutTheme.almostBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(100),
            ),
            child: CommonUtils.peanutCurrency(value: _quest.rewards.toString(), color: PeanutTheme.primaryColor),
          ),
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
          Text(_quest.description!),
        ],
      );
}

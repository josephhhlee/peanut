import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/Models/map_model.dart';
import 'package:peanut/Services/firestore_service.dart';

class Quest with ClusterItem {
  late final String? id;
  late final int? rewards;
  late final int? createdOn;
  late final String creator;

  String? title;
  String? description;
  String? taker;
  int? expiry;
  MapModel? mapModel;

  @override
  LatLng get location => LatLng(mapModel!.lat, mapModel!.lng);

  Quest.empty() {
    creator = DataStore().currentUser!.uid;
  }

  Quest.fromSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    final data = doc.data() as Map;

    mapModel = MapModel(addr: data["address"], lat: data["latitude"], lng: data["longitude"]);
    title = data["title"];
    description = data["description"];
    rewards = data["rewards"];
    createdOn = data["createdOn"]!.millisecondsSinceEpoch;
    expiry = data["expiry"];
    creator = data["creator"];
    taker = data["taker"];
  }

  Future<void> create() async {
    final ref = FirestoreService.questsCol.doc();
    id = ref.id;
    createdOn = DateTime.now().millisecondsSinceEpoch;
    await ref.set(toJson());
  }

  toJson() => {
        "id": id,
        "address": mapModel?.addr,
        "latitude": mapModel?.lat,
        "longitude": mapModel?.lng,
        "geohash": mapModel?.geohash,
        "title": title,
        "description": description,
        "rewards": rewards,
        "createdOn": DateTime.fromMillisecondsSinceEpoch(createdOn!),
        "expiry": expiry,
        "creator": creator,
        "taker": taker,
      };
}

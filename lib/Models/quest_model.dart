import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/Models/map_model.dart';
import 'package:peanut/Services/firestore_service.dart';

class Quest with ClusterItem {
  String? id;
  String? title;
  String? description;
  int? rewards;
  MapModel? mapModel;

  @override
  LatLng get location => LatLng(mapModel!.lat, mapModel!.lng);

  Quest.empty();

  Quest.fromSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    mapModel = MapModel(addr: doc.get("address"), lat: doc.get("latitude"), lng: doc.get("longitude"));
    title = doc.get("title");
    description = doc.get("description");
    rewards = doc.get("rewards");
  }

  Future<void> create() async {
    final ref = FirestoreService.questsCol.doc();
    id = ref.id;
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
      };
}

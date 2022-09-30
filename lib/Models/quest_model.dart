import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/configs.dart';
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
  int? deposit;
  bool completed = false;
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
    deposit = data["deposit"];
    creator = data["creator"];
    taker = data["taker"];
    completed = data["completed"] ?? false;
  }

  Map<String, dynamic> toJson() => {
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
        "deposit": deposit,
        "creator": creator,
        "taker": taker,
        "completed": completed,
      };

  Map<String, Map> _questListToJson() => {
        id!: {
          "address": mapModel?.addr,
          "title": title,
          "rewards": rewards,
          "createdOn": DateTime.fromMillisecondsSinceEpoch(createdOn!),
          "expiry": expiry,
          "creator": creator,
          "taker": taker,
          "completed": completed,
        },
      };

  Future<void> create(Transaction transaction) async {
    final questRef = FirestoreService.questsCol.doc();
    id = questRef.id;
    createdOn = DateTime.now().millisecondsSinceEpoch;

    transaction.set(questRef, toJson());
    transaction.set(FirestoreService.userQuestListCreatedDoc(creator), _questListToJson(), SetOptions(merge: true));
  }

  Future<void> update(Transaction transaction) async {
    final ref = FirestoreService.questsCol.doc(id);

    transaction.update(ref, toJson());
    transaction.update(FirestoreService.userQuestListCreatedDoc(creator), _questListToJson());
    if (taker != null) transaction.set(FirestoreService.userQuestListTakenDoc(taker!), _questListToJson(), SetOptions(merge: true));
  }

  Future<bool> questIsTaken() async {
    final doc = await FirestoreService.questsCol.doc(id).get();
    return doc.get("taker") != null;
  }

  void assignTaker(String uid) {
    taker = uid;
    deposit = Configs.questDepositCost;
  }
}

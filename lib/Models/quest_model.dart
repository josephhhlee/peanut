import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/Models/map_model.dart';
import 'package:peanut/Services/firestore_service.dart';

class MiniQuest {
  late final String? id;
  late final int? rewards;
  late final int? createdOn;
  late final String creator;

  String? title;
  String? taker;
  int? expiry;
  bool completed = false;
  MapModel? mapModel;

  MiniQuest.empty();

  MiniQuest.fromMap(String key, Map value) {
    id = key;
    mapModel = MapModel(addr: value["address"], lat: value["latitude"], lng: value["longitude"]);
    title = value["title"];
    rewards = value["rewards"];
    createdOn = value["createdOn"]!.millisecondsSinceEpoch;
    expiry = value["expiry"];
    creator = value["creator"];
    taker = value["taker"];
    completed = value["completed"] ?? false;
  }

  MiniQuest._fromSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    final data = doc.data() as Map;

    mapModel = MapModel(addr: data["address"], lat: data["latitude"], lng: data["longitude"]);
    title = data["title"];
    rewards = data["rewards"];
    createdOn = data["createdOn"]!.millisecondsSinceEpoch;
    expiry = data["expiry"];
    creator = data["creator"];
    taker = data["taker"];
    completed = data["completed"] ?? false;
  }

  Map<String, Map> _toJson() => {
        id!: {
          "address": mapModel?.addr,
          "latitude": mapModel?.lat,
          "longitude": mapModel?.lng,
          "title": title,
          "rewards": rewards,
          "createdOn": DateTime.fromMillisecondsSinceEpoch(createdOn!),
          "expiry": expiry,
          "creator": creator,
          "taker": taker,
          "completed": completed,
        },
      };

  void _create(Transaction transaction) => transaction.set(FirestoreService.userQuestListCreatedDoc(creator), _toJson(), SetOptions(merge: true));

  void _update(Transaction transaction) {
    transaction.set(FirestoreService.userQuestListCreatedDoc(creator), _toJson(), SetOptions(merge: true));
    if (taker != null) transaction.set(FirestoreService.userQuestListTakenDoc(taker!), _toJson(), SetOptions(merge: true));
  }
}

class Quest extends MiniQuest with ClusterItem {
  String? description;
  int? deposit;

  @override
  LatLng get location => LatLng(mapModel!.lat, mapModel!.lng);

  Quest.empty() : super.empty() {
    creator = DataStore().currentUser!.uid;
  }

  Quest.fromSnapshot(DocumentSnapshot doc) : super._fromSnapshot(doc) {
    final data = doc.data() as Map;

    description = data["description"];
    deposit = data["deposit"];
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

  Future<void> create(Transaction transaction) async {
    final questRef = FirestoreService.questsCol.doc();
    id = questRef.id;
    createdOn = DateTime.now().millisecondsSinceEpoch;

    transaction.set(questRef, toJson());
    super._create(transaction);
  }

  Future<void> update(Transaction transaction) async {
    final ref = FirestoreService.questsCol.doc(id);

    transaction.update(ref, toJson());
    super._update(transaction);
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

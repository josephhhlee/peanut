import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final appConfigs = FirebaseFirestore.instance.collection("appConfigs");
  static final users = FirebaseFirestore.instance.collection("users");
}

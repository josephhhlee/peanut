import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final appConfigs = FirebaseFirestore.instance.collection("appConfigs");
  static final onboarding = appConfigs.doc("onboarding");
  static final configs = appConfigs.doc("configs");
  static final maintenance = appConfigs.doc("maintenance");
  static final users = FirebaseFirestore.instance.collection("users");
}

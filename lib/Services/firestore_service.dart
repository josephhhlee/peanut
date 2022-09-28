import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static final appConfigsCol = _firestore.collection("appConfigs");
  static final usersCol = _firestore.collection("users");
  static final questsCol = _firestore.collection("quests");

  static final onboardingDoc = appConfigsCol.doc("onboarding");
  static final configsDoc = appConfigsCol.doc("configs");
  static final maintenanceDoc = appConfigsCol.doc("maintenance");

  static DocumentReference getPeanutCurrencyDoc(String uid) => usersCol.doc(uid).collection("currency").doc("peanut");
}

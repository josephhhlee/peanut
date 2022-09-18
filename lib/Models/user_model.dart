import 'package:cloud_firestore/cloud_firestore.dart';

class NutUser {
  late final String? uid;
  late final String? email;
  late final String? displayName;

  NutUser({this.uid, this.email, this.displayName});

  NutUser.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map;

    uid = data["uid"];
    email = data["email"];
    displayName = data["displayName"];
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "displayName": displayName,
      };
}

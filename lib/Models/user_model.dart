import 'package:cloud_firestore/cloud_firestore.dart';

class NutUser {
  late final String uid;
  late final String email;
  late String displayName;
  late String? displayPhoto;
  late bool verified;

  NutUser({required this.uid, required this.email, required this.displayName, this.displayPhoto, this.verified = false});

  NutUser.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map;

    uid = data["uid"];
    email = data["email"];
    displayName = data["displayName"];
    displayPhoto = data["displayPhoto"];
    verified = data["verified"];
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "displayName": displayName,
        "displayPhoto": displayPhoto,
        "verified": verified,
      };
}

import 'package:cloud_firestore/cloud_firestore.dart';

class NutUser {
  late final String uid;
  late final String email;
  late final int createdOn;
  late final PrivateData? private;

  late String displayName;
  late String? displayPhoto;
  late bool verified;

  NutUser({required this.uid, required this.email, required this.displayName, this.displayPhoto, this.verified = false, required this.createdOn});

  NutUser.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map;

    uid = data["uid"];
    email = data["email"];
    displayName = data["displayName"];
    displayPhoto = data["displayPhoto"];
    verified = data["verified"];
    createdOn = data["createdOn"]?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "displayName": displayName,
        "displayPhoto": displayPhoto,
        "verified": verified,
        "createdOn": DateTime.fromMillisecondsSinceEpoch(createdOn),
      };
}

class PrivateData {}

class CacheUser {
  final NutUser user;
  final int timestamp;

  const CacheUser({required this.user, required this.timestamp});
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peanut/Services/firestore_service.dart';

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
    createdOn = data["createdOn"]?.millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "displayName": displayName,
        "displayPhoto": displayPhoto,
        "verified": verified,
        "createdOn": DateTime.fromMillisecondsSinceEpoch(createdOn),
      };

  Future<int> getPeanutCurrency() async {
    final doc = await FirestoreService.peanutCurrencyDoc(uid).get();
    return doc.get("value");
  }

  Future<void> updatePeanutCurrency(int value, {Transaction? transaction}) async {
    final ref = FirestoreService.peanutCurrencyDoc(uid);
    final data = {"value": value};
    transaction != null ? transaction.update(ref, data) : await ref.update(data);
  }
}

class PrivateData {}

class CacheUser {
  final NutUser user;
  final int timestamp;

  const CacheUser({required this.user, required this.timestamp});
}

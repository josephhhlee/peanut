import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/Services/authentication_service.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Ui/Entrance/login.dart';
import 'package:peanut/Ui/General/maintenance.dart';

class MaintenanceService {
  static late StreamSubscription<DocumentSnapshot>? listener;

  static StreamSubscription<void> init() =>
      listener = FirestoreService.appConfigs.doc("maintenance").snapshots().listen((doc) async => await _updateMaintenanceStatus(doc));

  static Future<void> _updateMaintenanceStatus(DocumentSnapshot doc) async {
    Future<bool> isLoggedIn() async => await AuthenticationService.checkForLogin();

    if (doc.get("activate")) {
      Configs().maintenance = true;
      var msg = Map.from(doc.data() as Map)["customDescription"].trim();
      Configs().customMaintenanceMsg = msg.isEmpty ? null : msg;

      if (!Configs().connected) return;

      Navigation.navigator.routeManager.clearAndPush(Uri.parse(MaintenancePage.routeName));
    } else if (Navigation.navigator.currentConfiguration?.path == MaintenancePage.routeName) {
      Configs().maintenance = false;
      Navigation.navigator.routeManager.clearAndPush(Uri.parse(await isLoggedIn() ? HomePage.routeName : LoginPage.routeName));
    }
  }
}

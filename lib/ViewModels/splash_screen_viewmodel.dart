// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:peanut/Services/authentication_service.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Services/location_service.dart';
import 'package:peanut/Ui/Global/home_page.dart';

class SplashScreenViewModel {
  Future<void> init(BuildContext context) async {
    final loggedIn = await AuthenticationService.checkForLogin(redirect: true);
    if (loggedIn) {
      await LocationService.init(context);
      await initMapTheme();
      await initCurrentUser();
      DataStore().setDataInitialized(true);
      Navigation.push(context, HomePage.routeName);
    }
  }

  Future<void> initCurrentUser() async => DataStore().currentUser = NutUser.fromSnapshot(await FirestoreService.users.doc(FirebaseAuth.instance.currentUser!.uid).get());

  Future<void> initMapTheme() async => DataStore().mapTheme = await rootBundle.loadString('assets/themes/theme3.json');
}

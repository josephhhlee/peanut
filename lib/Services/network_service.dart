import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:peanut/App/configs.dart';
import 'dart:developer';
import 'package:peanut/App/router.dart';
import 'package:peanut/Services/authentication_service.dart';
import 'package:peanut/Ui/Entrance/login.dart';
import 'package:peanut/Ui/General/no_network.dart';
import 'package:peanut/Ui/General/page_not_found.dart';
import 'package:peanut/Ui/General/splash_screen.dart';

class NetworkService {
  static final Connectivity _connectivity = Connectivity();
  static late StreamSubscription<ConnectivityResult>? listener;
  static late Uri? _pageToResume;
  static late Timer? _networkTimer;

  static Future<void> init() async {
    await _initConnection();
    _networkListener();
  }

  static StreamSubscription<void> _networkListener() =>
      listener = _connectivity.onConnectivityChanged.listen((result) async => await _updateConnectionStatus(result));

  static Future<void> _initConnection() async {
    try {
      var result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
    }
  }

  static Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    Future<bool> isLoggedIn() async => await AuthenticationService.checkForLogin();

    void handleNoNetwork() {
      if (_networkTimer!.isActive || result != ConnectivityResult.none) return;
      Configs().connected = false;
      Navigation.navigator.routeManager.clearAndPush(Uri.parse(NoNetworkPage.routeName));
    }

    if (result == ConnectivityResult.none) {
      _pageToResume = Navigation.navigator.currentConfiguration!;
      _networkTimer = Timer(const Duration(seconds: 2), handleNoNetwork);
    } else {
      Configs().connected = true;
      _networkTimer?.cancel();

      if (_pageToResume != null) {
        var nonResumablePage = _pageToResume!.path.isEmpty ||
            _pageToResume!.path == PageNotFoundPage.routeName ||
            _pageToResume!.path == SplashScreenPage.routeName ||
            _pageToResume!.path == NoNetworkPage.routeName;

        if (nonResumablePage) {
          _pageToResume = Uri.parse(await isLoggedIn() ? HomePage.routeName : LoginPage.routeName);
          Navigation.navigator.routeManager.clearAndPush(_pageToResume!);
        } else {
          Navigation.navigator.routeManager.clearAndPushAll([Uri.parse(HomePage.routeName), _pageToResume!]);
        }
        _pageToResume = null;
      }
    }
  }
}

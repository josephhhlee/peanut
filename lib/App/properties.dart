import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:peanut/Services/authentication_service.dart';
import 'package:peanut/Ui/MainPages/peanut_map.dart';
import 'package:peanut/Utils/common_utils.dart';

class Properties {
  static Properties? _instance;
  Properties._();
  factory Properties() => _instance ??= Properties._();

  late final String env;

  void init() {
    navigationBarIndex = ValueNotifier(0);
    navigationQueue = ListQueue();
  }

  static late ValueNotifier<int> navigationBarIndex;
  static late ListQueue<int> navigationQueue;

  static bool _warnQuitApp = false;
  static Future<bool> onBack(BuildContext context) async {
    if (navigationQueue.isEmpty) {
      if (!_warnQuitApp) {
        CommonUtils.toast(context, "Press back again to exit");
        _warnQuitApp = true;
        return false;
      }
      return true;
    }

    int index = navigationQueue.removeLast();
    navigationBarIndex.value = index;
    return false;
  }

  static final Map<String, dynamic> _navigationScreens = {
    "Home": {
      "screen": const PeanutMap(),
      "icon": FontAwesomeIcons.mapLocation,
    },
    "Profile": {
      "screen": const TextButton(
        onPressed: AuthenticationService.logout,
        child: Text("LOG OUT"),
      ),
      "icon": Icons.settings,
    }
  };
  static List<Widget> get screens => _navigationScreens.values.map<Widget>((e) => e["screen"]).toList();
  static List<IconData> get icons => _navigationScreens.values.map<IconData>((e) => e["icon"]).toList();
  static List<String> get titles => _navigationScreens.keys.toList();
}

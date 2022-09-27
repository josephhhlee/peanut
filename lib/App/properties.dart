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

  static reset() {
    navigationBarIndex.value = 0;
    navigationQueue.clear();
  }

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

class MapProperties {
  static const streetAbbreviations = {
    "Ably": "Assembly",
    "Admin": "Administration",
    "Apt": "Apartment",
    "Ave": "Avenue",
    "Aye": "AYE",
    "Bke": "BKE",
    "Bldg": "Building",
    "Blk": "Block",
    "Blvd": "Boulevard",
    "Br": "Branch",
    "Bt": "Bukit",
    "Budd": "Buddhist",
    "Cath": "Cathedral",
    "Cbd": "CBD",
    "Cc": "Community Club",
    "Chbrs": "Chambers",
    "Cine": "Cinema",
    "Cl": "Close",
    "Clubhse": "Clubhouse",
    "Condo": "Condominium",
    "Cp": "Carpark",
    "Cplx": "Complex",
    "Cres": "Crescent",
    "Cte": "CTE",
    "Ctr": "Centre",
    "Ctrl": "Central",
    "Cwealth": "CommonWealth",
    "Dept": "Department",
    "Div": "Division",
    "Dr": "Drive",
    "Ecp": "ECP",
    "Edn": "Education",
    "Env": "Environment",
    "Est": "Estate",
    "Eway": "Expressway",
    "Fb": "Food Bridge",
    "Fc": "Food Centre",
    "Fty": "Factory",
    "Gdn": "Garden",
    "Gdns": "Gardens",
    "Govt": "Government",
    "Gr": "Grove",
    "Hosp": "Hospital",
    "Hq": "Headquarter",
    "Hse": "House",
    "Hts": "Heights",
    "Ind": "Industrial",
    "Inst": "Institute",
    "Instn": "Institution",
    "Intl": "International",
    "Jc": "Junior College",
    "Jln": "Jalan",
    "Jnr": "Junior",
    "Kg": "Kampong",
    "Kje": "KJE",
    "Kpe": "KPE",
    "Lib": "Library",
    "Lk": "Link",
    "Lor": "Lorong",
    "Mai": "Maisonette",
    "Man": "Mansion",
    "Mce": "MCE",
    "Meth": "Methodist",
    "Min": "Ministy",
    "Mkt": "Market",
    "Mt": "Mount",
    "Natl": "National",
    "Nth": "North",
    "Pie": "PIE",
    "Pk": "Park",
    "Pl": "Place",
    "Pri": "Primary",
    "Pt": "Point",
    "Rd": "Road",
    "Sch": "School",
    "Sec": "Secondary",
    "Sle": "SLE",
    "Sg": "Singapore",
    "Sq": "Square",
    "St": "Street",
    "St.": "Saint",
    "Sth": "South",
    "Stn": "Station",
    "Tc": "Town Council",
    "Ter": "Terrace",
    "Tg": "Tanjong",
    "Tpe": "TPE",
    "Upp": "Upper",
  };
}

import 'dart:developer';
import 'package:peanut/Services/firestore_service.dart';

class Configs {
  static Configs? _instance;
  Configs._();
  factory Configs() => _instance ??= Configs._();

  late final String env;

  Future<void> init({env}) async {
    log("Running in $env mode");
    await initRemoteConfig();

    this.env = env;
  }

  static late int displayNameCharLimit;
  static late int emailCharLimit;
  static late int passwordCharLimit;
  static late int descriptionCharLimit;
  static late int verificationResendTimer;
  static late int geohashPrecision;
  static late int cacheExpiry;
  static late double mapZoomLevel;
  static late String googleMapsApi;
  static late String androidBundleId;
  static late String androidSHA1;
  static late String googleAndroidApi;
  static late bool enableSuggestions;
  static bool pause = false;

  static Future<void> initRemoteConfig() async {
    try {
      final doc = await FirestoreService.configsDoc.get();
      final map = doc.data();
      final charLimits = Map.from(map!["character_limits"]);
      final timers = Map.from(map["timers"]);
      final maps = Map.from(map["maps"]);
      final android = Map.from(map["android"]);

      displayNameCharLimit = charLimits["display_name"];
      emailCharLimit = charLimits["email"]!;
      passwordCharLimit = charLimits["password"]!;
      descriptionCharLimit = charLimits["description"];
      verificationResendTimer = timers["verification_resend"];
      cacheExpiry = (timers["cache_expiry_in_minutes"] * 60000);
      mapZoomLevel = maps["zoom"].toDouble();
      googleMapsApi = maps["api"];
      geohashPrecision = maps["geohash_precision"];
      enableSuggestions = maps["enable_suggestions"];
      androidBundleId = android["bundle_id"];
      androidSHA1 = android["signing_sha1"];
      googleAndroidApi = android["google_api"];
    } catch (e) {
      log(e.toString());
      pause = true;
    }
  }

  bool connected = false;
  bool maintenance = false;
  String? customMaintenanceMsg;
}

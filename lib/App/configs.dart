import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:developer';

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

  static late int? displayNameCharLimit;
  static late int? emailCharLimit;
  static late int? passwordCharLimit;

  static Future<void> initRemoteConfig() async {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();

    displayNameCharLimit = remoteConfig.getInt("display_name_character_limit");
    emailCharLimit = remoteConfig.getInt("email_character_limit");
    passwordCharLimit = remoteConfig.getInt("password_character_limit");
  }

  bool connected = false;
  bool maintenance = false;
  String? customMaintenanceMsg;
}

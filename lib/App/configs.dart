import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:developer';

class Configs {
  static Configs? _instance;
  Configs._();
  factory Configs() => _instance ??= Configs._();

  late final String env;

  Future<void> init({env}) async {
    log("Running in $env mode");

    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();

    this.env = env;
  }

  bool connected = false;
  bool maintenance = false;
  String? customMaintenanceMsg;
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStore with ChangeNotifier {
  static DataStore? _instance;
  DataStore._();
  factory DataStore() => _instance ??= DataStore._();

  late final SharedPreferences pref;
  late final SecureStorage secureStorage;

  bool dataInitialised = false;

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    secureStorage = SecureStorage();
  }

  void setDataInitialized(bool dataInitialised) {
    this.dataInitialised = dataInitialised;

    if (!dataInitialised) {}
    notifyListeners();
  }
}

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> clearCache() async {
    await _storage.deleteAll(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(
      key: key,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<dynamic> read(String key) async {
    var value = await _storage.read(
      key: key,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
    return value == null ? value : jsonDecode(value);
  }

  Future<void> write(String key, dynamic value) async {
    await _storage.write(
      key: key,
      value: jsonEncode(value),
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<void> remove(String key) async {
    await _storage.delete(
      key: key,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(resetOnError: true, encryptedSharedPreferences: false);

  IOSOptions _getIOSOptions() => const IOSOptions(accessibility: KeychainAccessibility.first_unlock);
}
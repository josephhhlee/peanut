import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/properties.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class DataStore with ChangeNotifier {
  static DataStore? _instance;
  DataStore._();
  factory DataStore() => _instance ??= DataStore._();

  late final SharedPreferences pref;
  late final SecureStorage secureStorage;

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    secureStorage = SecureStorage();
  }

  @override
  void dispose() {
    _peanutCurrencyListener?.cancel();
    super.dispose();
  }

  String? mapTheme;

  bool dataInitialised = false;

  int? currentUserPeanutCurrency;
  StreamSubscription<DocumentSnapshot>? _peanutCurrencyListener;
  NutUser? _currentUser;
  NutUser? get currentUser => _currentUser;
  set currentUser(NutUser? user) {
    _currentUser = user;
    if (user != null) {
      _peanutCurrencyListener = FirestoreService.getPeanutCurrencyDoc(user.uid).snapshots().listen((doc) {
        currentUserPeanutCurrency = doc.get("value");
        notifyListeners();
      });
    }
  }

  void setDataInitialized(bool dataInitialised) {
    this.dataInitialised = dataInitialised;

    if (!dataInitialised) {
      currentUser = null;
      currentUserPeanutCurrency = null;
      _peanutCurrencyListener?.cancel();
      _peanutCurrencyListener = null;
      Properties.reset();
      secureStorage.clearCache();
    }
    notifyListeners();
  }

  LocationData? locationData;
  void updateLocation(LocationData locationData) {
    this.locationData = locationData;
    notifyListeners();
  }

  void addLocationListener(Function(LocationData? location) function) => addListener(() => function(locationData));

  Map<String, CacheUser> userCache = {};
  Future<NutUser?> getUser(String? uid, {bool fromDB = false}) async {
    void addUserCache(NutUser user) {
      final cacheUser = CacheUser(user: user, timestamp: DateTime.now().millisecondsSinceEpoch);
      userCache[uid!] = cacheUser;
    }

    Future<NutUser> fetchFromDB() async {
      final doc = await FirestoreService.usersCol.doc(uid).get();
      final user = NutUser.fromSnapshot(doc);
      if (uid != currentUser!.uid) addUserCache(user);
      return user;
    }

    Future<NutUser> fetchFromCache() async {
      if (uid == currentUser!.uid) return currentUser!;

      var cacheUser = userCache[uid];
      if (cacheUser == null) {
        return await fetchFromDB();
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        final isExpired = (now - cacheUser.timestamp) > Configs.cacheExpiry;
        return isExpired ? await fetchFromDB() : cacheUser.user;
      }
    }

    if (uid == null || uid.isEmpty) return null;

    try {
      if (fromDB) {
        return await fetchFromDB();
      } else {
        return await fetchFromCache();
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
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

class CachedUserData extends StatefulWidget {
  final String uid;
  final Widget Function(NutUser user) builder;
  final Widget? placeHolder;

  const CachedUserData({super.key, required this.uid, required this.builder, this.placeHolder});

  @override
  State<CachedUserData> createState() => _CachedUserDataState();
}

class _CachedUserDataState extends State<CachedUserData> {
  NutUser? user;
  bool initialized = false;
  late Widget placeHolder;

  @override
  void initState() {
    placeHolder = widget.placeHolder ?? const SizedBox.shrink();
    initialize().whenComplete(() {
      initialized = true;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  Future initialize() async => user = await DataStore().getUser(widget.uid);

  @override
  Widget build(BuildContext context) {
    return initialized && user != null ? widget.builder(user!) : placeHolder;
  }
}

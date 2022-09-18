import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/Services/maintenance_service.dart';
import 'package:peanut/Services/network_service.dart';
import 'package:peanut/firebase_options.dart';
import 'package:provider/provider.dart';

void main({env = "dev"}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform(env: env));

  await Configs().init(env: env);
  await DataStore().init();

  if (env != "prod") await DataStore().pref.remove("onboarding");

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: PeanutTheme.transparent, statusBarIconBrightness: Brightness.dark));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: env == "prod" ? 1 : 0),
        ChangeNotifierProvider(create: (_) => DataStore()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  const MyApp({super.key});

  Future<void> _init() async {
    Navigation.init();
    await _initListeners();
  }

  Future<void> _initListeners({excludeState = false}) async {
    void stateListener(String trigger) =>
        trigger == "start" ? WidgetsBinding.instance.addObserver(this) : WidgetsBinding.instance.removeObserver(this);

    if (!excludeState) stateListener("start");
    await NetworkService.init();
    MaintenanceService.init();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive) await DataStore().secureStorage.clearCache();
    if (state != AppLifecycleState.resumed) {
      NetworkService.listener?.cancel();
      MaintenanceService.listener?.cancel();
    } else {
      _initListeners(excludeState: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _init();

    return MaterialApp.router(
      title: "Peanut",
      theme: PeanutTheme.defaultTheme(),
      darkTheme: PeanutTheme.defaultTheme(),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale.fromSubtags(languageCode: 'en', countryCode: 'SG')],
      routeInformationParser: InformationParser(),
      routerDelegate: Navigation.navigator,
    );
  }
}

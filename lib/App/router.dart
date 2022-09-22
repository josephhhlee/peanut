import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:peanut/App/configs.dart';
import 'package:peanut/Services/authentication_service.dart';
import 'package:peanut/Ui/Entrance/login_page.dart';
import 'package:peanut/Ui/Entrance/signup_page.dart';
import 'package:peanut/Ui/Entrance/verify_page.dart';
import 'package:peanut/Ui/General/maintenance_page.dart';
import 'package:peanut/Ui/General/no_network_page.dart';
import 'package:peanut/Ui/General/page_not_found_page.dart';
import 'package:peanut/Ui/Entrance/splash_screen_page.dart';
import 'package:peanut/Ui/Global/home_page.dart';
import 'package:peanut/Ui/MainPages/add_quest_page.dart';
import 'package:peanut/Utils/animation_utils.dart';
import 'package:velocity_x/velocity_x.dart';

class InformationParser extends VxInformationParser {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    var path = routeInformation.location;
    var routeName = path;
    if (path!.contains("?")) routeName = path.substring(0, path.indexOf("?"));
    var isLoggedIn = await AuthenticationService.checkForLogin();

    return Uri.parse(path);
  }

  @override
  RouteInformation restoreRouteInformation(Uri configuration) {
    return RouteInformation(location: Uri.decodeComponent(configuration.toString()));
  }
}

class PeanutRouter {
  static Map<Pattern, Page Function(Uri, dynamic)> routes() {
    return {
      SplashScreenPage.routeName: (_, __) => const MaterialPage(child: SplashScreenPage()),
      LoginPage.routeName: (_, __) => const MaterialPage(child: LoginPage()),
      SignUpPage.routeName: (_, __) => const MaterialPage(child: SignUpPage()),
      HomePage.routeName: (_, __) => const MaterialPage(child: HomePage()),
      PageNotFoundPage.routeName: (_, __) => const MaterialPage(child: PageNotFoundPage()),
      NoNetworkPage.routeName: (_, __) => const MaterialPage(child: NoNetworkPage()),
      MaintenancePage.routeName: (_, __) => const MaterialPage(child: MaintenancePage()),
      AddQuestPage.routeName: (_, __) => VxRoutePage(child: const AddQuestPage(), transition: fabTransition),
      VerifyPage.routeName: (_, arg) => MaterialPage(child: VerifyPage(arg)),
    };
  }

  static Widget fabTransition(Animation<double> animation, Widget child) {
    final screenSize = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    return ClipPath(
      clipper: CircularRevealClipper(
        centerOffset: Offset(screenSize.width / 2, screenSize.height - 50),
        fraction: animation.value,
      ),
      child: child,
    );
  }
}

class Navigation {
  static VxNavigator? navigator;

  static init() => navigator = VxNavigator(routes: PeanutRouter.routes(), observers: [Observer()], notFoundPage: (_, __) => const MaterialPage(child: PageNotFoundPage()));

  static Future<dynamic> push(BuildContext context, String path, {dynamic args, bool wait = false, bool replace = false, bool clear = false}) async {
    if (replace) {
      return await context.vxNav.replace(Uri.parse(path), params: args);
    } else if (clear) {
      return await context.vxNav.clearAndPush(Uri.parse(path), params: args);
    } else {
      return await context.vxNav.push(Uri.parse(path), params: args);
    }
  }

  static void pop(BuildContext context, {dynamic result}) => context.vxNav.pop();

  static void popUntil(BuildContext context, String path) {
    while (navigator?.currentConfiguration?.path != path) {
      var currentPage = navigator?.currentConfiguration?.path;
      if (currentPage == "/" || currentPage == HomePage.routeName || currentPage == LoginPage.routeName) break;
      pop(context);
    }
  }

  static void popUntilHome(BuildContext context) => popUntil(context, "/");
}

class Observer extends VxObserver {
  @override
  Future<void> didChangeRoute(Uri route, Page page, String pushOrPop) async {
    log("${route.path} - $pushOrPop");

    final configs = Configs();
    if (!configs.connected) {
      if (route.path == NoNetworkPage.routeName) return;
      return Navigation.navigator?.routeManager.clearAndPush(Uri.parse(NoNetworkPage.routeName));
    } else if (configs.maintenance) {
      if (route.path == MaintenancePage.routeName) return;
      return Navigation.navigator?.routeManager.clearAndPush(Uri.parse(MaintenancePage.routeName));
    }
  }
}

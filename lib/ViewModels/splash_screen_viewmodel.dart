import 'package:peanut/Services/authentication_service.dart';

class SplashScreenViewModel {
  Future<void> init() async =>
      await Future.delayed(const Duration(seconds: 1), () async => await AuthenticationService.checkForLogin(redirect: true));
}

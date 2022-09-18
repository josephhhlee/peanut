import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:peanut/App/data_store.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/Models/user_model.dart';
import 'package:peanut/Services/firestore_service.dart';
import 'package:peanut/Ui/Entrance/login_page.dart';
import 'dart:developer';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationService {
  static final _auth = FirebaseAuth.instance;

  static Future<bool> checkForLogin({bool redirect = false}) async {
    Future<bool> process() async {
      await logout();
      if (redirect) Navigation.navigator?.routeManager.clearAndPush(Uri.parse(LoginPage.routeName));
      return false;
    }

    try {
      var currentUser = _auth.currentUser;
      if (currentUser == null) return await process();
      return true;
    } catch (e) {
      log("failed login -  $e");
      return await process();
    }
  }

  static Future<void> logout() async {
    Future<void> checkIfGoogleSignIn() async {
      GoogleSignInAccount? googleSignInAccount = GoogleSignIn().currentUser;
      bool googleSignIn = await GoogleSignIn().isSignedIn();
      if (googleSignInAccount != null && googleSignIn) {
        await GoogleSignIn().disconnect();
      }
    }

    DataStore().setDataInitialized(false);
    await checkIfGoogleSignIn().catchError((e) => log("Google Sign In Error: $e"));
    await FirebaseAuth.instance.signOut().catchError((e) => log("FirebaseAuth Logout Error: $e"));
  }

  static Future<void> loginWithEmail(String email, String password, {bool signup = false}) async {
    try {
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signup && signInMethods.isNotEmpty) throw "Another account is already associated with this email. Please login.";

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser;

      log("Logged In with - ${user?.uid}");
    } catch (e) {
      log(e.toString());
      throw "Error ${signup ? "signing up" : "logging in"} with Email.";
    }
  }

  static Future<void> loginWithApple({bool signup = false}) async {
    try {
      if (!await SignInWithApple.isAvailable()) throw "Apple ${signup ? "Sign Up" : "Log In"} is not available for your device.";

      final credential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
      final oauthCredential = OAuthProvider("apple.com").credential(idToken: credential.identityToken);
      final authResult = await _auth.signInWithCredential(oauthCredential);
      final user = authResult.user;
      final doc = await FirestoreService.users.doc(user!.uid).get();
      final userExist = doc.exists;

      if (signup && !userExist) {
        final nutUser = NutUser(displayName: credential.givenName, email: credential.email?.toLowerCase(), uid: user.uid);
        await FirestoreService.users.doc(nutUser.uid).set(nutUser.toJson());
      }

      log("Logged In with - ${user.uid}");
    } catch (e) {
      log(e.toString());
      throw "Error ${signup ? "signing up" : "logging in"} with Apple.";
    }
  }

  static Future<void> loginWithGoogle({bool signup = false}) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) throw "Error ${signup ? "signing up" : "logging in"} with Google.";

      final userCredential = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: (await account.authentication).idToken, accessToken: (await account.authentication).accessToken));
      final user = userCredential.user;
      final doc = await FirestoreService.users.doc(user!.uid).get();
      final userExist = doc.exists;

      if (signup && !userExist) {
        final nutUser = NutUser(displayName: user.displayName, email: user.email?.toLowerCase(), uid: user.uid);
        await FirestoreService.users.doc(nutUser.uid).set(nutUser.toJson());
      }

      log("Logged In with - ${user.uid}");
    } catch (e) {
      log(e.toString());
      throw "Error ${signup ? "signing up" : "logging in"} with Google.";
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
      throw "Error resetting password.";
    }
  }
}

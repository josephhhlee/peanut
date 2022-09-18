import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:peanut/App/router.dart';
import 'package:peanut/App/theme.dart';
import 'package:peanut/Services/authentication_service.dart';
import 'package:peanut/Utils/common_utils.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "/login";

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmail = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _resetFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isResetPassword = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isResetPassword) {
          setState(() {
            _formKey.currentState?.reset();
            _isResetPassword = false;
            _resetEmail.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: PeanutTheme.transparent,
        body: PeanutTheme.background(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(),
              Flexible(
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanDown: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: _showLoginMenu(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20),
      child: IconButton(
        onPressed: () {
          if (_isResetPassword) {
            setState(() {
              _formKey.currentState?.reset();
              _isResetPassword = false;
              _resetEmail.clear();
            });
            return;
          }
          Navigation.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          size: 35.0,
        ),
      ),
    );
  }

  Widget _showLoginMenu() {
    var width = MediaQuery.of(context).size.width < 500 ? MediaQuery.of(context).size.width : 500.0;
    var menuPadding = 30.0;
    var otherSignIWidth = 120.0;
    var displaySignInsInRow = width - (menuPadding * 2) > otherSignIWidth * 3;

    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 75),
      padding: EdgeInsets.symmetric(horizontal: menuPadding),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _isResetPassword
              ? [
                  _title("Password Reset", "Enter registered email to continue"),
                  const SizedBox(height: 55),
                  _textForm("Email", _resetEmail, _resetFocusNode),
                  const SizedBox(height: 45),
                  _mainButton("reset"),
                ]
              : [
                  _title("Login", "Please sign in to continue"),
                  const SizedBox(height: 55),
                  _otherSigninOptions(displaySignInsInRow, otherSignIWidth),
                  _or(),
                  _textForm("Email", _emailController, _emailFocusNode),
                  const SizedBox(height: 20),
                  _textForm("Password", _passwordController, _passwordFocusNode),
                  const SizedBox(height: 45),
                  _mainButton("login"),
                  _forgotPW(),
                  const SizedBox(height: 35),
                  _dontHaveAcc(),
                ],
        ),
      ),
    );
  }

  Widget _or() {
    Widget divider = Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        color: PeanutTheme.greyDivider,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          divider,
          const Text(
            "OR",
            style: TextStyle(color: PeanutTheme.almostBlack),
          ),
          divider,
        ],
      ),
    );
  }

  Widget _title(String header, String desc) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
          ),
          Text(
            desc,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _textForm(String hint, TextEditingController controller, FocusNode focusNode) {
    return TextFormField(
      autofocus: false,
      controller: controller,
      focusNode: focusNode,
      obscureText: hint == "Password" && !_showPassword,
      style: const TextStyle(color: PeanutTheme.almostBlack),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        filled: true,
        fillColor: PeanutTheme.white,
        border: const OutlineInputBorder(),
        labelText: hint,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: controller.text.isNotEmpty && hint != "Password",
              child: IconButton(
                onPressed: () {
                  controller.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            Visibility(
              visible: controller.text.isNotEmpty && hint == "Password",
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: PeanutTheme.almostBlack),
              ),
            ),
          ],
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      validator: (value) {
        if (hint == "Password") {
          if (value!.isEmpty) {
            return "Password is empty";
          }
        }
        if (hint == "Email") {
          if (value!.isEmpty) {
            return "Email is empty";
          }
        }
        return null;
      },
    );
  }

  Widget _mainButton(String button) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
        onPressed: () async {
          FocusScope.of(context).unfocus();
          var validate = _formKey.currentState?.validate();
          if (!validate!) return;

          try {
            if (button == "reset") {
              await AuthenticationService.resetPassword(_resetEmail.text).whenComplete(() {
                CommonUtils.toast(context, "An email will be sent to your registered email shortly\nPlease check your email");
                _resetEmail.clear();
                setState(() => _isResetPassword = false);
              });
            } else {
              await AuthenticationService.loginWithEmail(_emailController.text, _passwordController.text)
                  .whenComplete(() => Navigation.push(context, HomePage.routeName, clear: true));
            }
          } catch (e) {
            CommonUtils.toast(context, e.toString(), backgroundColor: PeanutTheme.errorColor);
          }
        },
        child: Text(button.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _forgotPW() {
    return TextButton(
      onPressed: () {
        setState(() {
          _formKey.currentState?.reset();
          _isResetPassword = true;
          _passwordController.clear();
        });
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(fontSize: 13, decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _otherSigninOptions(bool displayInRow, double width) {
    width = !displayInRow ? width : width;

    return displayInRow
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _otherSignin(FontAwesomeIcons.google, "google", width),
              Visibility(
                visible: !Platform.isIOS,
                child: _otherSignin(FontAwesomeIcons.apple, "apple", width),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _otherSignin(FontAwesomeIcons.google, "google", width),
              Visibility(
                visible: Platform.isIOS,
                child: _otherSignin(FontAwesomeIcons.apple, "apple", width),
              ),
            ],
          );
  }

  Widget _otherSignin(IconData icon, String signInOption, double width) {
    return GestureDetector(
      onTap: () async {
        Future<void> login() async {
          try {
            if (signInOption == "google") {
              await AuthenticationService.loginWithGoogle();
            } else if (signInOption == "apple") {
              await AuthenticationService.loginWithApple();
            }
          } catch (e) {
            rethrow;
          }
        }

        try {
          await login().whenComplete(() => Navigation.push(context, HomePage.routeName));
        } catch (e) {
          CommonUtils.toast(context, e.toString(), backgroundColor: PeanutTheme.errorColor);
        }
      },
      child: Container(
        height: 35,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.only(right: 20, left: 5, top: 5, bottom: 5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: PeanutTheme.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(width: 1, color: PeanutTheme.primaryColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              child: signInOption == "google"
                  ? Image.asset(
                      "assets/logos/google_light.png",
                      package: "flutter_signin_button",
                      fit: BoxFit.cover,
                      width: 40,
                    )
                  : SizedBox(
                      height: 25,
                      width: 40,
                      child: Icon(icon, size: 20, color: PeanutTheme.black),
                    ),
            ),
            const Expanded(
              child: Text(
                "SIGN IN",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dontHaveAcc() {
    var textSize = 12.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have account? ",
          style: TextStyle(
            fontSize: textSize,
            color: PeanutTheme.almostBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () async {
            Navigation.push(context, SignUpPage.routeName);
            await Future.delayed(const Duration(milliseconds: 500), () => _formKey.currentState?.reset());
          },
          child: Text(
            "Sign up",
            style: TextStyle(
              fontSize: textSize + 1,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

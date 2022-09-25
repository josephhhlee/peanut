import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:peanut/App/theme.dart';

class Loading {
  static Widget loadingIndicator({double size = 30}) => Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: PeanutTheme.primaryColor,
          secondRingColor: PeanutTheme.almostBlack,
          thirdRingColor: PeanutTheme.secondaryColor,
          size: size,
        ),
      );
}

class LoadingOverlay {
  static BuildContext? _dialogContext;

  static Future build(BuildContext context) async => await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        _dialogContext = dialogContext;
        return WillPopScope(
          onWillPop: () async => false,
          child: Loading.loadingIndicator(),
        );
      });

  static pop() {
    if (_dialogContext != null) Navigator.pop(_dialogContext!);
    _dialogContext == null;
  }
}

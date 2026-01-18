import 'dart:io' show Platform, exit;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dialogs.dart';

class ExitDialogNavigatorObserver extends NavigatorObserver {
  static bool _isDialogShowing = false;

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    if (!_isDialogShowing) {
      _showExitDialog();
    }
  }

  Future<void> _showExitDialog() async {
    final context = navigator?.context;
    if (context == null || _isDialogShowing) return;

    _isDialogShowing = true;
    final shouldExit = await Dialogs.showExitConfirmation(context);
    _isDialogShowing = false;

    if (shouldExit) {
      if (Platform.isAndroid || Platform.isIOS) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    }
  }
}

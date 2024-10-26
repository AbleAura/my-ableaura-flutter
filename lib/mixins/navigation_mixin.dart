// Create a new file: lib/mixins/navigation_mixin.dart

import 'package:flutter/material.dart';

mixin NavigationMixin {
  GlobalKey<NavigatorState> get navigatorKey;

  void navigateTo(BuildContext context, String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }

  void navigateAndReplace(BuildContext context, String routeName) {
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void navigateAndRemoveUntil(BuildContext context, String routeName) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  void goBack(BuildContext context) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
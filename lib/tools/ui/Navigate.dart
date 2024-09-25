// This code is translated from Kotlin to Dart, using Flutter framework.

import 'package:flutter/material.dart';

class Navigate {
  static void safeNavigateTo(NavigatorState navigatorState, int actionId, {Object? arguments}) {
    final Route<dynamic>? currentRoute = navigatorState.context.widget;
    // Assuming we have a way to check the current route's actions
    if (currentRoute != null && currentRoute.settings.name == actionId.toString()) {
      navigatorState.pushNamed(actionId.toString(), arguments: arguments);
    }
  }
}
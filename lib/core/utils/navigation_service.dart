import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> navigateToReplacement(Widget screen) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static Future<dynamic> navigateToAndRemoveUntil(Widget screen) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }
}

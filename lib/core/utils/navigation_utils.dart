// lib/core/utils/navigation_utils.dart
import 'package:flutter/material.dart';

class NavigationUtils {
  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static void navigateToScreenWithReplacement(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

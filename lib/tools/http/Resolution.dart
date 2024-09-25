// Translated from Kotlin to Dart
// Framework: Flutter

import 'package:shared_preferences/shared_preferences.dart';

class Resolution {
  final RegExp original;

  Resolution(this.original);

  int get imageResolution {
    final preferences = SharedPreferences.getInstance();
    preferences.then((prefs) {
      final resolutionString = prefs.getString('imgResolutionKeyID');
      // print("MyResolution: use image resolution: $resolutionString");
      return resolutionString != null ? int.parse(resolutionString) : 1500;
    });
    return 1500; // Default resolution if preferences are not yet loaded
  }

  String wrap(String url) {
    return url.replaceAll(original, 'c${imageResolution}x.');
  }
}
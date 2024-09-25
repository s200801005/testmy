// This code is a translation from Kotlin Android to Dart Flutter
import 'package:flutter/material.dart';

class ActivityTemplate extends StatefulWidget {
  @override
  _ActivityTemplateState createState() => _ActivityTemplateState();
}

class _ActivityTemplateState extends State<ActivityTemplate> {
  late UITools toolsBox;
  final BoolPref preferences = BoolPref();
  
  bool get allFullScreen => preferences.get('allFullScreen') ?? false;

  @override
  void initState() {
    super.initState();
    toolsBox = UITools();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (allFullScreen) {
      // Set system UI flags for full-screen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    }
  }
}

class BoolPref {
  bool? get(String key) {
    // Implement shared preferences retrieval here
    return false; // Placeholder for the actual retrieval logic
  }

  void set(String key, bool value) {
    // Implement shared preferences storage here
  }
}

class UITools {
  // Assume there are methods and properties related to UI tools
}
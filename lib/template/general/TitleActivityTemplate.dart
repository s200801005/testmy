// This code is translated from Kotlin to Dart for a Flutter application.
import 'package:flutter/material.dart';

class TitleActivityTemplate extends ActivityTemplate {
  @override
  void initState() {
    super.initState();
    ilogo.onClick = () {
      onBackPressed();
    };
  }
}
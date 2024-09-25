// This code is translated from Kotlin to Dart, using Flutter framework.
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Font {
  static Typeface? nisiTypeFace;

  static Typeface? getNisiTypeFace(BuildContext context) {
    if (nisiTypeFace != null) return nisiTypeFace;
    nisiTypeFace = _loadFont(context);
    return nisiTypeFace;
  }

  static Typeface? _loadFont(BuildContext context) {
    // Assuming that R.font.nisi corresponds to a font asset in Flutter.
    // Replace with actual font loading logic as needed.
    return Typeface.load('assets/fonts/nisi.ttf');
  }
}
// Dart code translated from Kotlin. The code defines a custom ToggleButton-like widget.
import 'package:flutter/material.dart';

class ChapterToggleButton extends ToggleButton {
  ChapterToggleButton({
    Key? key,
    required BuildContext context,
    required List<bool> isSelected,
    required Function(int) onPressed,
  }) : super(
          key: key,
          isSelected: isSelected,
          onPressed: onPressed,
        );

  String? url;
  String? caption;
  int index = 0;
  String? uuid;
  String chapterName = "null" {
    didChangeDependencies() {
      super.didChangeDependencies();
      // Assuming this is where you set the text properties based on chapterName
      textOn = chapterName;
      textOff = chapterName;
      text = chapterName;
    }
  }
}
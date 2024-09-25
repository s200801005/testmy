// This code is translated from Java to Dart.
// It uses Dart's built-in data structures and syntax.

import '../manga/MangaDlTools.dart';
import 'ComicStructure.dart';
import 'ReturnBase.dart';
import 'ThemeStructure.dart';

class BookInfoStructure extends ReturnBase {
  late Results results;

  // Inner class Results extending ResultsBase
  static class Results extends ResultsBase {
    ComicStructure comic;
    Map<String, ThemeStructure> groups; // Using Dart's Map instead of HashMap
  }
}
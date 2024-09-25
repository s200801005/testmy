// Translated from Java to Dart
// Framework: Dart

import '../manga/MangaDlTools.dart';
import 'ReturnBase.dart';

class BookListStructure extends ReturnBase {
  Results results;

  static class Results {
    int total;
    List<ComicStructure> list;
    int limit;
    int offset;
  }
}
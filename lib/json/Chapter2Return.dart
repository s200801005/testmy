// This code is a translation from Java to Dart, reflecting a similar structure and purpose.
import 'ChapterWithContent.dart';
import 'ComicStructure.dart';
import 'ReturnBase.dart';

class Chapter2Return extends ReturnBase {
  Results results;

  static class Results extends ResultsBase {
    ComicStructure comic;
    ChapterWithContent chapter;
  }
}
// This code is translated from Java to Dart.
import 'ChapterStructure.dart';

class ChapterWithContent extends ChapterStructure {
  List<UUIDUrlPair> contents;
  List<int> words;
  bool isLong;

  ChapterWithContent({this.contents, this.words, this.isLong});
}
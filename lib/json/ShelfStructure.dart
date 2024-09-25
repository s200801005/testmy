// Translated from Java to Dart
// Framework: Dart

import 'HistoryComicStructure.dart';
import 'LastBrowseStructure.dart';
import 'ReturnBase.dart';

class ShelfStructure extends ReturnBase {
  Results results;

  static class Results extends InfoBase {
    List<ListItem> list;

    static class ListItem {
      int uuid;
      bool isFolder;
      LastBrowseStructure lastBrowse;
      HistoryComicStructure comic;
    }
  }
}
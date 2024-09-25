// This code is a translation from Java to Dart

class HistoryBookListStructure extends ReturnBase {
  Results results;

  class Results {
    List<ListItem> list;
    int total;
    int limit;
    int offset;
  }

  class ListItem {
    String lastChapterId;
    String lastChapterName;
    HistoryComicStructure comic;
  }
}
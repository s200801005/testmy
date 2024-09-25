// Translated from Java to Dart
class BookQueryStructure extends ReturnBase {
  Results results;

  class Results {
    Browse browse;
    int collect;
    bool isLock;
    bool isLogin;
    bool isMobileBind;
    bool isVip;

    class Browse {
      String comicUuid;
      String comicId;
      String pathWord;
      String chapterUuid;
      String chapterId;
      String chapterName;
    }
  }
}
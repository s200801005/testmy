// Using Dart with classes

class HistoryComicStructure {
  String uuid;
  bool isDisplayed;
  String name;
  String pathWord;
  List<ThemeStructure> authors;
  List<ThemeStructure> themes;
  String cover;
  int status;
  int popularity;
  String updatedDatetime;
  String lastChapterId;
  String lastChapterName;
  Browse browse;

  HistoryComicStructure({
    required this.uuid,
    required this.isDisplayed,
    required this.name,
    required this.pathWord,
    required this.authors,
    required this.themes,
    required this.cover,
    required this.status,
    required this.popularity,
    required this.updatedDatetime,
    required this.lastChapterId,
    required this.lastChapterName,
    required this.browse,
  });
}

class Browse {
  String comicUuid;
  String pathWord;
  String chapterUuid;
  String chapterName;

  Browse({
    required this.comicUuid,
    required this.pathWord,
    required this.chapterUuid,
    required this.chapterName,
  });
}
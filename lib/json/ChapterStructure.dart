// This is a Dart class representation of a ChapterStructure in a Flutter application.
class ChapterStructure {
  int index;
  String uuid;
  int count;
  int size;
  String name;
  String comicId; // Renamed for better clarity
  String comicPathWord; // Renamed for better clarity
  String groupId; // Renamed for better clarity
  String groupPathWord; // Renamed for better clarity
  int type;
  int imgType; // Renamed for better clarity
  String datetimeCreated; // Renamed for better clarity
  String prev;
  String next;

  ChapterStructure({
    required this.index,
    required this.uuid,
    required this.count,
    required this.size,
    required this.name,
    required this.comicId,
    required this.comicPathWord,
    required this.groupId,
    required this.groupPathWord,
    required this.type,
    required this.imgType,
    required this.datetimeCreated,
    required this.prev,
    required this.next,
  });
}
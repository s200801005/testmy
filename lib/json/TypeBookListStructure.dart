// This code is translated from Java to Dart.
import '../manga/MangaDlTools.dart';
import 'ReturnBase.dart';

class TypeBookListStructure extends ReturnBase {
  late Results results;

  static class Results {
    int total;
    List<TypeBook> list;
    int limit;
    int offset;
  }

  static class TypeBook {
    int type;
    String name;
    String datetimeCreated;
    ComicStructure comic;
  }
}
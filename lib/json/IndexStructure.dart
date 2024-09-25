// This code is translated from Java to Dart
import '../manga/MangaDlTools.dart';
import 'ReturnBase.dart';

class IndexStructure extends ReturnBase {
  late Results results;

  static class Results {
    List<Banners> banners;
    Topics topics;
    RecComics recComics;
    RankComics rankDayComics;
    RankComics rankWeekComics;
    RankComics rankMonthComics;
    List<ComicWrap> hotComics;
    List<ComicWrap> newComics;
    FinishComics finishComics;

    static class Banners {
      int type;
      String cover;
      String brief;
      String outUuid; // Changed to follow Dart naming conventions
      ComicStructure comic;
    }

    static class Topics extends InfoBase {
      List<ListItem> list; // Changed List[] to List<ListItem>

      static class ListItem { // Changed List to ListItem to avoid naming conflict
        String title;
        SeriesStructure series;
        String journal;
        String cover;
        String period;
        int type;
        String brief;
        String pathWord; // Changed to follow Dart naming conventions
        String datetimeCreated; // Changed to follow Dart naming conventions
      }
    }

    static class RecComics extends InfoBase {
      List<ListItem> list; // Changed List[] to List<ListItem>

      static class ListItem { // Changed List to ListItem to avoid naming conflict
        int type;
        ComicStructure comic;
      }
    }

    static class RankComics extends InfoBase {
      List<InfoStructure> list; // Changed InfoStructure[] to List<InfoStructure>
    }

    static class ComicWrap {
      ComicStructure comic;
    }

    static class FinishComics extends InfoBase {
      List<ComicStructure> list; // Changed ComicStructure[] to List<ComicStructure>
      String pathWord; // Changed to follow Dart naming conventions
      String name;
      String type;
    }
  }
}
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class InfoCardLoader extends StatefulWidget {
  final int inflateRes;
  final int navId;
  final bool isTypeBook;
  final bool isHistoryBook;
  final bool isShelfBook;

  InfoCardLoader({
    required this.inflateRes,
    required this.navId,
    this.isTypeBook = false,
    this.isHistoryBook = false,
    this.isShelfBook = false,
  });

  @override
  _InfoCardLoaderState createState() => _InfoCardLoaderState();
}

class _InfoCardLoaderState extends State<InfoCardLoader> {
  var offset = 0;
  String get subUrl => getApiUrl();
  PausableDownloader? ad;

  @override
  Future<void> addPage() async {
    await super.addPage();
    setProgress(20);
    ad = PausableDownloader(subUrl) { data ->
      if (isRefresh) {
        page = 0;
        isRefresh = false;
      }
      if (widget.isTypeBook) {
        final bookList = TypeBookListStructure.fromJson(jsonDecode(data));
        bookList?.apply((results) {
          debugPrint("offset:${results.offset}, total:${results.total}");
          if (results.offset < results.total) {
            if (code == 200) {
              final size = results.list?.length ?? 0;
              results.list?.forEachIndexed((i, book) {
                debugPrint("load @ $i");
                if (ad?.exit == true) return;
                cardList?.addCard(
                  book?.comic?.name ?? "null",
                  null,
                  book?.comic?.cover,
                  book?.comic?.path_word,
                  null,
                  null,
                  isFinish: false,
                  isNew: false,
                );
                setProgress(20 + 80 * i / size);
              });
              offset += size;
            }
          }
          page++;
        });
      } else if (widget.isHistoryBook) {
        final bookList = HistoryBookListStructure.fromJson(jsonDecode(data));
        bookList?.apply((results) {
          debugPrint("offset:${results?.offset}, total:${results?.total}");
          if (results.offset < results.total) {
            if (code == 200) {
              final size = results?.list?.length ?? 0;
              results?.list?.forEachIndexed((i, book) {
                debugPrint("load @ $i");
                if (ad?.exit == true) return;
                cardList?.addCard(
                  book?.comic?.name ?? "null",
                  "\n云读至${book?.last_chapter_name}",
                  book?.comic?.cover,
                  book?.comic?.path_word,
                  null,
                  null,
                  book?.comic?.status == 1,
                );
                setProgress(20 + 80 * i / size);
              });
              offset += size;
            }
          }
          page++;
        });
      } else if (widget.isShelfBook) {
        final bookList = ShelfStructure.fromJson(jsonDecode(data));
        bookList?.apply((results) {
          debugPrint("offset:${results?.offset}, total:${results?.total}");
          if (results.offset < results.total) {
            if (code == 200) {
              final size = results?.list?.length ?? 0;
              results?.list?.forEachIndexed((i, book) {
                debugPrint("load @ $i");
                if (ad?.exit == true) return;
                cardList?.addCard(
                  book?.comic?.name ?? "null",
                  "\n${book?.last_browse?.last_browse_name?.let((it) => "读到$it") ?? "未读"}",
                  book?.comic?.cover,
                  book?.comic?.path_word,
                  null,
                  null,
                  book?.comic?.status == 1,
                  book.comic?.browse?.chapter_uuid != book.comic?.last_chapter_id,
                );
                setProgress(20 + 80 * i / size);
              });
              offset += size;
            }
          }
          page++;
        });
      } else {
        final bookList = BookListStructure.fromJson(jsonDecode(data));
        bookList?.apply((results) {
          debugPrint("offset:${results?.offset}, total:${results?.total}");
          if (results.offset < results.total) {
            if (code == 200) {
              final size = results?.list?.length ?? 0;
              results?.list?.forEachIndexed((i, book) {
                debugPrint("load @ $i");
                if (ad?.exit == true) return;
                cardList?.addCard(
                  book?.name ?? "null",
                  null,
                  book?.cover,
                  book?.path_word,
                  null,
                  null,
                  false,
                );
                setProgress(20 + 80 * i / size);
              });
              offset += size;
            }
          }
          page++;
        });
      }
      onLoadFinish();
    };
    try {
      ad?.run();
    } catch (e) {
      debugPrint(e.toString());
      try {
        Navigator.of(context).pop();
      } catch (_) {}
    }
  }

  @override
  void initCardList(WeakReference<State<StatefulWidget>> weakReference) {
    super.initCardList(weakReference);
    cardList = CardList(weakReference, cardWidth, cardHeight, cardPerRow);
    cardList?.initClickListeners = (v, name, path, chapterUUID, pn) {
      v.setOnClickListener(() {
        final bundle = Bundle();
        bundle.putString("path", path);
        Navigate.safeNavigateTo(findNavController(), widget.navId, bundle);
      });
    };
  }

  String getApiUrl() {
    return "";
  }

  @override
  Future<void> onLoadFinish() async {
    if (ad?.exit != true) super.onLoadFinish();
  }

  @override
  Future<void> reset() async {
    super.reset();
    offset = 0;
  }

  @override
  void onCreate(Bundle? savedInstanceState) {
    super.onCreate(savedInstanceState);
    ad?.exit = false;
  }

  @override
  void onResume() {
    super.onResume();
    ad?.exit = false;
  }

  @override
  void onDestroy() {
    super.onDestroy();
    ad?.exit = true;
  }

  void delayedRefresh(int timeMillis) {
    Future.delayed(Duration(milliseconds: timeMillis), () {
      showKanban();
      reset();
      addPage();
      hideKanban();
    });
  }
}


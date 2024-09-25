import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MangaDlTools {
  DownloadPool? pool;
  String grp = "";
  Map<String, int> indexMap = {};

  bool get exit => pool?.exit ?? false;
  set exit(bool value) {
    pool?.exit = value;
  }

  bool? get wait => pool?.wait;
  set wait(bool? value) {
    if (value != null) {
      pool?.wait = value;
    }
  }

  Future<void> downloadChapterInVol(String url, String chapterName, String group, int index) async {
    debugPrint("下载：$url, index：$index");
    PausableDownloader(url, 1000).run().then((data) {
      try {
        final chapter2Return = Chapter2Return.fromJson(jsonDecode(data));
        downloadChapter(chapter2Return, index, chapterName, group);
      } catch (e) {
        debugPrint(e.toString());
        onDownloadedListener?.handleMessage(index, false, e.toString());
      }
    }).catchError((error) {
      onDownloadedListener?.handleMessage(index, false, "获取章节信息错误");
    });
  }

  void prepareDownloadListener() {
    pool?.setOnDownloadListener((fileName, isSuccess, message) {
      indexMap[fileName]?.let((index) {
        onDownloadedListener?.handleMessage(index, isSuccess, message);
      });
    });
    pool?.setOnPageDownloadListener((fileName, downloaded, total, isSuccess, message) {
      indexMap[fileName]?.let((index) {
        onDownloadedListener?.handleMessage(index, downloaded, total, isSuccess, message);
      });
    });
  }

  void setPool(String comicName, String group) {
    if (pool == null || grp != group) {
      final directory = await getApplicationDocumentsDirectory();
      pool = DownloadPool(File('${directory.path}/$comicName/$group'));
      grp = group;
      prepareDownloadListener();
    }
  }

  void setIndexMap(String f, int index) {
    indexMap[f] = index;
  }

  void downloadChapter(Chapter2Return chapter2Return, int index, String chapterName, String group) {
    if (index >= 0) {
      final f = "$chapterName.zip";
      setPool(chapter2Return.results.comic.name, group);
      setIndexMap(f, index);
      pool?.add(DownloadPool.Quest(f, getMangaUrls(chapter2Return)));
    }
  }

  List<String> getMangaUrls(Chapter2Return chapter2Return) {
    List<String> re = [];
    Map<int, String> hm = {};
    final chapter = chapter2Return.results.chapter;
    if (chapter.words.length < chapter.contents.length) {
      chapter.words = List<int>.from(chapter.words)
        ..addAll(List<int>.generate(chapter.contents.length, (index) => index));
    }
    for (int i = 0; i < chapter.contents.length; i++) {
      hm[chapter.words[i]] = chapter.contents[i].url;
    }
    for (int i = 0; i < chapter.contents.length; i++) {
      re.add(hm[i] ?? "");
    }
    return re;
  }

  OnDownloadedListener? onDownloadedListener;
}

abstract class OnDownloadedListener {
  void handleMessage(int index, bool isSuccess, String message);
  void handleMessage(int index, int downloaded, int total, bool isSuccess, String message);
}

class DownloadPool {
  bool exit = false;
  bool? wait;

  DownloadPool(File directory);

  void setOnDownloadListener(Function(String fileName, bool isSuccess, String message) listener) {}
  void setOnPageDownloadListener(Function(String fileName, int downloaded, int total, bool isSuccess, String message) listener) {}
  void add(Quest quest) {}
}

class PausableDownloader {
  PausableDownloader(String url, int timeout);

  Future<String> run() async {
    // Implement the download logic here
    return "";
  }
}

class Chapter2Return {
  Results results;

  Chapter2Return.fromJson(Map<String, dynamic> json)
      : results = Results.fromJson(json['results']);
}

class Results {
  Comic comic;
  Chapter chapter;

  Results.fromJson(Map<String, dynamic> json)
      : comic = Comic.fromJson(json['comic']),
        chapter = Chapter.fromJson(json['chapter']);
}

class Comic {
  String name;

  Comic.fromJson(Map<String, dynamic> json) : name = json['name'];
}

class Chapter {
  List<int> words;
  List<Content> contents;

  Chapter.fromJson(Map<String, dynamic> json)
      : words = List<int>.from(json['words']),
        contents = List<Content>.from(json['contents'].map((x) => Content.fromJson(x)));
}

class Content {
  String url;

  Content.fromJson(Map<String, dynamic> json) : url = json['url'];
}

class Quest {
  String fileName;
  List<String> urls;

  Quest(this.fileName, this.urls);
}


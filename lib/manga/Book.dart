import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../json/BookInfoStructure.dart';
import '../json/ThemeStructure.dart';
import '../json/VolumeStructure.dart';

class Book {
  final String path;
  final String Function(int) getString;
  final Directory exDir;
  final bool loadCache;
  final String? mPassName;

  late final String mBookApiUrl;
  late final String mUserAgent;
  BookInfoStructure? mBook;
  List<String> mGroupPathWords = [];
  List<String> mKeys = [];
  List<int> mCounts = [];
  List<VolumeStructure> mVolumes = [];
  String mJsonString = "";
  bool exit = false;

  Book(this.path, this.getString, this.exDir, {this.loadCache = false, this.mPassName}) {
    mBookApiUrl = getString(R.string.bookInfoApiUrl).replaceAll('{}', CMApi.myHostApiUrl + path);
    mUserAgent = getString(R.string.pc_ua).replaceAll('{}', DownloadTools.app_ver);
  }

  String? get name => mBook?.results?.comic?.name ?? mPassName;
  String? get cover => mBook?.results?.comic?.cover;
  File? get cachedCover {
    final mangaFolder = name != null ? Directory('${exDir.path}/$name') : null;
    if (mangaFolder == null) return null;
    final head = File('${mangaFolder.path}/head.jpg');
    if (!head.existsSync()) return null;
    return head;
  }

  String get region => mBook?.results?.comic?.region?.display ?? "未知";
  List<ThemeStructure>? get author => mBook?.results?.comic?.author;
  List<ThemeStructure>? get theme => mBook?.results?.comic?.theme;
  List<String> get keys => mKeys;

  String get imageType {
    switch (mBook?.results?.comic?.img_type) {
      case 1:
        return "条漫";
      case 2:
        return "普通";
      default:
        return "未知类型${mBook?.results?.comic?.img_type}";
    }
  }

  int get popular => mBook?.results?.comic?.popular ?? 0;
  String get status => mBook?.results?.comic?.status?.display ?? "未知";
  String get updateTime => mBook?.results?.comic?.datetime_updated ?? "未知";
  String get brief => mBook?.results?.comic?.brief ?? "空简介";
  List<VolumeStructure> get volumes => mVolumes;
  String? get uuid => mBook?.results?.comic?.uuid;
  String get json => mJsonString;

  Book.fromName(String name, String Function(int) getString, Directory exDir)
      : this(Reader.getComicPathWordInFolder(Directory('${exDir.path}/$name')), getString, exDir, true, name);

  Future<void> updateInfo() async {
    try {
      bool isDownload = false;
      List<int> data;
      if (loadCache) {
        final name = this.name;
        if (name != null) {
          data = await loadInfo(name);
        } else {
          isDownload = true;
          data = await DownloadTools.getHttpContent(mBookApiUrl, null, mUserAgent);
        }
      } else {
        isDownload = true;
        data = await DownloadTools.getHttpContent(mBookApiUrl, null, mUserAgent);
      }

      mBook = BookInfoStructure.fromJson(jsonDecode(utf8.decode(data)));
      if (isDownload) {
        await saveInfo(data);
      }

      mGroupPathWords = [];
      mKeys = [];
      mCounts = [];
      mBook?.results?.groups?.values?.forEach((it) {
        mKeys.add(it.name);
        mGroupPathWords.add(it.path_word);
        if (it.count == 0) {
          it.count = 1;
        }
        mCounts.add(it.count);
        debugPrint("Add caption: ${it.name} @ ${it.path_word} of ${it.count}");
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateVolumes(Future<void> Function() whenFinish) async {
    bool isDownload = false;
    List<VolumeStructure> volumes;
    if (loadCache && await loadVolumes()) {
      volumes = mVolumes;
    } else {
      volumes = [];
    }

    if (volumes.isEmpty) {
      isDownload = true;
      for (int i = 0; i < mGroupPathWords.length; i++) {
        final g = mGroupPathWords[i];
        final volume = Volume(path, g, getString);
        if (volume.exit) {
          return;
        }
        final updatedChapters = await volume.updateChapters(mCounts[i]);
        if (updatedChapters != null) {
          volumes.addAll(updatedChapters);
        }
      }
    }

    if (!exit && volumes.length == mGroupPathWords.length) {
      if (isDownload) {
        await saveVolumes(volumes);
        mVolumes = volumes;
      }
      goSaveHead(isDownload);
      await whenFinish();
    }
  }

  Future<void> saveVolumes(List<VolumeStructure> volumes) async {
    final name = this.name;
    if (name != null) {
      final mangaFolder = Directory('${exDir.path}/$name');
      if (!mangaFolder.existsSync()) {
        await mangaFolder.create(recursive: true);
      }
      mJsonString = jsonEncode(volumes);
      await File('${mangaFolder.path}/info.json').writeAsString(mJsonString);
      await File('${mangaFolder.path}/grps.json').writeAsString(jsonEncode(mKeys));
    }
  }

  void goSaveHead(bool force) {
    final name = this.name;
    if (name != null) {
      final mangaFolder = Directory('${exDir.path}/$name');
      if (!mangaFolder.existsSync()) {
        mangaFolder.createSync(recursive: true);
      }
      final f = File('${mangaFolder.path}/head.jpg');
      if (force || !f.existsSync()) {
        final coverUrl = cover != null ? CMApi.imageProxy?.wrap(cover!) ?? cover : null;
        if (coverUrl != null) {
          Thread(() async {
            final data = await DownloadTools.getHttpContent(coverUrl, -1);
            if (data != null) {
              await f.writeAsBytes(data);
            }
          }).start();
        }
      }
    }
  }

  Future<bool> loadVolumes() async {
    final name = this.name;
    if (name != null) {
      final mangaFolder = Directory('${exDir.path}/$name');
      if (!mangaFolder.existsSync()) {
        await mangaFolder.create(recursive: true);
      }
      final jsonFile = File('${mangaFolder.path}/info.json');
      if (!jsonFile.existsSync()) return false;
      mJsonString = await jsonFile.readAsString();
      mVolumes = (jsonDecode(mJsonString) as List).map((e) => VolumeStructure.fromJson(e)).toList();
      final groupFile = File('${mangaFolder.path}/grps.json');
      if (!groupFile.existsSync()) return false;
      mKeys = (jsonDecode(await groupFile.readAsString()) as List).cast<String>();
      return true;
    }
    return false;
  }

  Future<void> saveInfo(List<int> data) async {
    final name = this.name;
    if (name != null) {
      final mangaFolder = Directory('${exDir.path}/$name');
      if (!mangaFolder.existsSync()) {
        await mangaFolder.create(recursive: true);
      }
      await File('${mangaFolder.path}/meta.json').writeAsBytes(data);
    }
  }

  Future<List<int>?> loadInfo(String name) async {
    final mangaFolder = Directory('${exDir.path}/$name');
    if (!mangaFolder.existsSync()) {
      await mangaFolder.create(recursive: true);
    }
    final f = File('${mangaFolder.path}/meta.json');
    if (!f.existsSync()) return null;
    return await f.readAsBytes();
  }
}


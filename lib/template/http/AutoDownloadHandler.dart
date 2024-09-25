// Dart translation of Kotlin source code. Framework: Flutter

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:your_package_name/api/cm_api.dart';
import 'package:your_package_name/tools/download_tools.dart';
import 'package:your_package_name/json/return_base.dart';
import 'package:your_package_name/main_activity.dart';
import 'package:crypto/crypto.dart';

class AutoDownloadHandler {
  final String url;
  final Type jsonClass;
  final BuildContext? context;
  final bool loadFromCache;
  final File? customCacheFile;
  int checkTimes = 0;
  bool exit = false;

  AutoDownloadHandler(this.url, this.jsonClass, this.context,
      {this.loadFromCache = false, this.customCacheFile});

  void handleMessage(int message) {
    if (message == MSG_START_LOAD) {
      setLayouts();
    }
  }

  bool setGsonItem(dynamic gsonObj) => true;

  ReturnBase? getGsonItem() => null;

  Future<void> onError() async {}

  Future<void> doWhenFinishDownload() async {}

  void startLoad() {
    handleMessage(MSG_START_LOAD);
  }

  void destroy() {
    exit = true;
  }

  Future<void> download() async {
    checkTimes = 0;
    await downloadCoroutine();
    await check();
  }

  String toHexStr(List<int> byteArray) {
    return byteArray.map((byte) {
      String hex = byte & 0xFF < 16 ? '0' : '' + (byte & 0xFF).toRadixString(16);
      return hex;
    }).join('');
  }

  Future<void> downloadCoroutine() async {
    final cacheName = toHexStr(md5.convert(utf8.encode(url)).bytes);
    final cacheFile = customCacheFile ?? File('${MainActivity.mainWeakReference?.value?.externalCacheDir?.path}/$cacheName');

    if (loadFromCache) {
      if (await cacheFile.exists()) {
        bool pass = true;
        try {
          final jsonString = await cacheFile.readAsString();
          pass = setGsonItem(json.decode(jsonString));
        } catch (e) {
          print(e);
        }
        if (pass) return;
      }
    }

    int cnt = 0;
    while (cnt++ <= 3) {
      try {
        final data = await DownloadTools.getHttpContent(CMApi.apiProxy?.wrap(url) ?? url);
        if (exit) return;
        final fi = data.inputStream();
        final pass = setGsonItem(json.decode(await fi.readAsString()));
        if (pass && loadFromCache) {
          await cacheFile.writeAsBytes(data);
        }
        await fi.close();
        if (!pass) {
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
        break;
      } catch (e) {
        print(e);
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }

  Future<void> check() async {
    final gsonItem = getGsonItem();
    if (gsonItem != null) {
      print('[${gsonItem.code}]${gsonItem.message}');
      if (gsonItem.code == 200) {
        startLoad();
      }
    } else {
      await onError();
    }
  }

  Future<void> setLayouts() async {
    if (getGsonItem() == null) {
      await download();
    } else {
      await doWhenFinishDownload();
    }
  }

  static const int MSG_START_LOAD = 0;
}
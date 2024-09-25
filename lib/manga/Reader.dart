// Translated from Kotlin to Dart
// Framework: Flutter

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:your_package_name/view_manga_activity.dart'; // Update with your actual package name
import 'package:your_package_name/volume_structure.dart'; // Update with your actual package name
import 'package:your_package_name/main_activity.dart'; // Update with your actual package name
import 'package:your_package_name/preferences.dart'; // Update with your actual package name
import 'package:json_annotation/json_annotation.dart'; // Update with your actual package name
import 'dart:convert';

class Reader {
  static List<File> fileArray = [];

  static void startToViewManga(String? name, int position, List<String> urlArray, List<String> uuidArray, {bool fromFirstPage = false}) {
    print("MyR: viewMangaAt name $name, pos $position");
    var mainActivity = MainActivity.mainWeakReference?.get();
    if (mainActivity != null) {
      // ViewMangaActivity.dlhandler = null
      var intent = MaterialPageRoute(builder: (context) => ViewMangaActivity());
      if (name != null) {
        Preferences.setInt(name, position);
        print("MyR: 记录 $name 阅读到第 ${position + 1} 话");
        intent.settings.name = name;
      }
      intent.settings.name = position.toString();
      intent.settings.name = jsonEncode(urlArray);
      intent.settings.name = jsonEncode(uuidArray);
      if (!fromFirstPage) {
        intent.settings.name = "log";
        intent.settings.name = (-2).toString();
      }
      var zipFile = fileArray[position];
      if (zipFile.existsSync()) {
        intent.settings.name = zipFile.absolute.path;
        //intent.settings.name = "zipFirst";
      }
      Navigator.push(context, intent);
    }
  }

  static void viewOldMangaZipFile(List<File> fileArray, String name, int position, File zipFile) {
    Reader.fileArray = fileArray;
    var mainActivity = MainActivity.mainWeakReference?.get();
    if (mainActivity != null) {
      var intent = MaterialPageRoute(builder: (context) => ViewMangaActivity());
      intent.settings.name = name;
      intent.settings.name = position.toString();
      intent.settings.name = zipFile.absolute.path;
      Navigator.push(context, intent);
    }
  }

  static void viewMangaZipFile(int position, List<String> urlArray, List<String> uuidArray, File zipFile) {
    var mainActivity = MainActivity.mainWeakReference?.get();
    if (mainActivity != null) {
      var intent = MaterialPageRoute(builder: (context) => ViewMangaActivity());
      intent.settings.name = position.toString();
      intent.settings.name = jsonEncode(urlArray);
      intent.settings.name = jsonEncode(uuidArray);
      intent.settings.name = "zipFirst";
      intent.settings.name = zipFile.absolute.path;
      Navigator.push(context, intent);
    }
  }

  static String getComicPathWordInFolder(File file) {
    if (!file.existsSync()) {
      return "N/A:!file.exists()";
    }
    var jsonFile = File('${file.path}/info.json');
    if (!jsonFile.existsSync()) {
      return "N/A:!jsonFile.exists()";
    }
    var volumes = jsonDecode(jsonFile.readAsStringSync());
    if (volumes.isEmpty) {
      return "N/A:volumes.isEmpty()";
    }
    if (volumes[0]['results']['list'].isEmpty) {
      return "N/A:volumes[0].results.list.isEmpty()";
    }
    return volumes[0]['results']['list'][0]['comic_path_word'];
  }
}
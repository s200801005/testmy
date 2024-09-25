// Flutter framework and Dart programming language
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google.gson.dart';
import 'package:your_package_name/volume_structure.dart'; // Replace with actual import for VolumeStructure
import 'package:your_package_name/no_back_refresh_fragment.dart';

import '../../template/general/NoBackRefreshFragment.dart'; // Replace with actual import for NoBackRefreshFragment

class ComicDlFragment extends NoBackRefreshFragment {
  ComicDlFragment() : super(key: Key('fragment_dlcomic'));

  View? ltButton;
  static ComicDlHandler? handler;
  static String? json;
  static bool exit = false;

  @override
  void initState() {
    super.initState();
    exit = false;
  }

  @override
  void onViewCreated(BuildContext context) {
    super.onViewCreated(context);
    // Set padding for ldwn (assuming it's a Widget)
    ldwn?.padding = EdgeInsets.only(top: 0, left: 0, right: 0, bottom: navBarHeight);
    
    if (isFirstInflate) {
      Future(() async {
        if (arguments["callFromOldDL"] == true) {
          await initOldComicData();
        } else if (arguments.containsKey("loadJson")) {
          String? name = arguments["name"];
          Directory? home = await getExternalFilesDir();
          if (home != null && name != null) {
            await Future.delayed(Duration(milliseconds: 600));
            print("MyCDF: loadJson by arguments");
            startToLoad(
              loadFromJson(arguments["loadJson"]!),
              true,
              loadGroupsFromFile(File('${home.path}/$name/grps.json')),
            );
          }
        } else {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    // mainWeakReference?.get()?.menuMain?.let { setMenuInvisible(it) }
    handler?.downloading = false;
    handler?.mangaDlTools?.exit = true;
    handler?.dismiss();
    exit = true;
    handler = null;
  }

  Future<void> startToLoad(List<VolumeStructure> volumes, {bool isFromFile = false, List<String>? groupArray}) async {
    handler = ComicDlHandler(
      Looper.myLooper()!,
      WeakReference(this),
      volumes,
      arguments["name"] ?? "null",
      isFromFile ? groupArray : arguments["groupNames"],
    );

    if (!isFromFile) {
      Directory? home = await getExternalFilesDir();
      String? name = arguments["name"];
      if (home != null && name != null) {
        Directory mangaFolder = Directory('${home.path}/$name');
        if (!mangaFolder.existsSync()) {
          mangaFolder.createSync();
        }
        File('${mangaFolder.path}/info.json').writeAsStringSync(Gson().toJson(volumes));
        if (arguments["groupNames"] != null) {
          File('${mangaFolder.path}/grps.json').writeAsStringSync(Gson().toJson(arguments["groupNames"]));
        }
      }
    }
    handler?.startLoad();
  }

  List<VolumeStructure> loadFromJson(String json) {
    return Gson().fromJson(json, List<VolumeStructure>.type);
  }

  List<String> loadGroupsFromFile(File file) {
    return Gson().fromJson(file.readAsStringSync(), List<String>.type);
  }

  Future<void> initOldComicData() async {
    handler = ComicDlHandler(
      Looper.myLooper()!,
      WeakReference(this),
      arguments["name"] ?? "null",
    );
    handler?.startLoad();
  }
}
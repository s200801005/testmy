import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewDownloadFragment extends StatefulWidget {
  @override
  _NewDownloadFragmentState createState() => _NewDownloadFragmentState();
}

class _NewDownloadFragmentState extends State<NewDownloadFragment> {
  List<File>? sortedBookList;
  String oldDlCardName = 'Old Download Card Name';
  Directory? extDir;
  bool isReverse = false;
  bool isContentChanged = false;
  bool exit = false;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    super.dispose();
    exit = true;
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showAll = prefs.getBool('settings_cat_md_sw_show_0m_manga') ?? false;
  }

  Future<void> addPage() async {
    if (isRefresh) {
      page = 0;
      isRefresh = false;
    }
    if (isEnd) {
      onLoadFinish();
      return;
    }
    setProgress(20);
    if (sortedBookList == null || isContentChanged) {
      print("Sorting books...");
      extDir = await getExternalStorageDirectory();
      sortedBookList = extDir?.listSync().toList();
      var size = sortedBookList?.length ?? 0;
      if (size > 0) {
        if (!showAll) {
          sortedBookList = getNonEmptyMangaList(sortedBookList);
        }
        setProgress(40);
        size = sortedBookList?.length ?? 0;
        var cache = <String, String>{};
        sortedBookList = sortedBookList?.sortedBy((it) {
          setProgress(60 + 20 * cache.length / size);
          return it.absolute.path.toLowerCase();
        });
        setProgress(60);
        if (isReverse) {
          print("reversed...");
          sortedBookList = sortedBookList?.reversed.toList();
        }
        setProgress(80);
      }
      isContentChanged = false;
    }
    print("Start drawing cards");
    var cnt = 0;
    if (page == 0) {
      cardList?.addCard(oldDlCardName, path: oldDlCardName);
      cnt = 1;
    }
    var size = sortedBookList?.length ?? 0;
    sortedBookList?.forEach((i) {
      if (cardList?.exitCardList != false) return;
      page++; // page is actually count
      var chosenJson = File('${i.path}/info.bin');
      var newJson = File('${i.path}/info.json');
      var bookSize = sizeOf(i).let((sz) {
        var m = (sz / 1048576).toInt();
        return m > 0 ? '\n${m}MB' : '\n${(sz / 1024).toInt()}KB';
      });
      if (chosenJson.existsSync()) {
        return; // unsupported old folder
      } else if (newJson.existsSync()) {
        if (cardList?.exitCardList != false) return;
        cardList?.addCard(i.path.split('/').last, bookSize);
        cnt++;
      }
      setProgress(80 + 20 * (cnt - 1) / size);
      if (cnt >= 21) return;
    });
    if (page >= sortedBookList!.length) {
      isEnd = true;
    }
    setProgress(99);
    onLoadFinish();
  }

  void initCardList(WeakReference<StatefulWidget> weakReference) {
    cardList = CardList(weakReference, cardWidth, cardHeight, cardPerRow);
    cardList?.initClickListeners = InitClickListeners(
      prepareListeners: (v, name, path, chapterUUID, pn) {
        v.onTap = () {
          if (name == oldDlCardName && path == oldDlCardName) {
            Navigate.safeNavigateTo(findNavController(), 'action_nav_new_download_to_nav_download');
            return;
          }
          callBookFragment(name);
        };
        v.onLongPress = () {
          if (name == oldDlCardName && path == oldDlCardName) {
            return false;
          }
          var chosenFile = File('${extDir?.path}/$name');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                icon: Icon(Icons.launch),
                title: Text('New Download Card Option Hint'),
                content: Text('Delete data folder or go to download page'),
                actions: [
                  TextButton(
                    child: Text('Delete'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(Icons.launch),
                            title: Text('Confirm'),
                            content: Text('Delete downloaded manga $name?'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  if (chosenFile.existsSync()) {
                                    chosenFile.deleteSync(recursive: true);
                                    setState(() {
                                      v.visibility = View.INVISIBLE;
                                    });
                                  }
                                },
                              ),
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  TextButton(
                    child: Text('Go to Download'),
                    onPressed: () {
                      callDownloadFragment(name);
                    },
                  ),
                ],
              );
            },
          );
          return true;
        };
      },
    );
  }

  void callBookFragment(String name) {
    var bundle = {'loadJson': true, 'name': name};
    Navigate.safeNavigateTo(findNavController(), 'action_nav_new_download_to_nav_book', bundle);
  }

  void callDownloadFragment(String name) {
    var bundle = {
      'loadJson': File('${extDir?.path}/$name/info.json').readAsStringSync(),
      'name': name
    };
    Navigate.safeNavigateTo(findNavController(), 'action_nav_new_download_to_nav_group', bundle);
  }

  void showReverseInfo(UITools toolsBox) {
    if (exit) return;
    toolsBox.buildInfo('Reverse Sort', 'Display downloaded manga in reverse order', 'Confirm', null, 'Cancel', () {
      isReverse = !isReverse;
      isContentChanged = true;
      Future.delayed(Duration(milliseconds: 600), () {
        showKanban();
        reset();
        addPage();
        hideKanban();
      });
    });
  }

  List<File> getNonEmptyMangaList(List<File> list) {
    // Implementation of getNonEmptyMangaList
    return list;
  }

  int sizeOf(File file) {
    // Implementation of sizeOf
    return 0;
  }

  void setProgress(int progress) {
    // Implementation of setProgress
  }

  void onLoadFinish() {
    // Implementation of onLoadFinish
  }

  void showKanban() {
    // Implementation of showKanban
  }

  void reset() {
    // Implementation of reset
  }

  void hideKanban() {
    // Implementation of hideKanban
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Download Fragment'),
      ),
      body: Center(
        child: Text('New Download Fragment'),
      ),
    );
  }
}

class CardList {
  // Implementation of CardList
}

class InitClickListeners {
  final Function(dynamic v, String name, String? path, String? chapterUUID, int? pn) prepareListeners;

  InitClickListeners({required this.prepareListeners});
}

class UITools {
  void buildInfo(String title, String message, String confirmText, String? neutralText, String cancelText, Function onConfirm) {
    // Implementation of buildInfo
  }
}

class Navigate {
  static void safeNavigateTo(dynamic navController, String action, [dynamic bundle]) {
    // Implementation of safeNavigateTo
  }
}

class WeakReference<T> {
  // Implementation of WeakReference
}

class FileUtils {
  static void recursiveRemove(File file) {
    // Implementation of recursiveRemove
  }
}


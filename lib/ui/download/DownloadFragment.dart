import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_toast/flutter_toast.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class DownloadFragment extends StatefulWidget {
  @override
  _DownloadFragmentState createState() => _DownloadFragmentState();
}

class _DownloadFragmentState extends State<DownloadFragment> {
  WeakReference<DownloadFragment>? wd;

  @override
  void initState() {
    super.initState();
    wd = WeakReference(this);
  }

  @override
  void dispose() {
    super.dispose();
    wd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ModalRoute.of(context)?.settings.arguments as String? ?? ''),
      ),
      body: FutureBuilder(
        future: initScan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index]),
                  onTap: () => onItemTap(snapshot.data![index]),
                  onLongPress: () => onItemLongPress(snapshot.data![index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<String>> initScan() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final filePath = args?['file'] as String?;
    final directory = filePath != null ? Directory(filePath) : await getApplicationDocumentsDirectory();

    if (filePath == null || !await directory.exists()) {
      Navigator.of(context).pop();
      return [];
    }

    final files = directory.listSync().where((f) => f is Directory).map((f) => f.path).toList();
    files.sort((a, b) {
      if (a.endsWith('.zip') && b.endsWith('.zip')) {
        return (10000 * getFloat(a) - 10000 * getFloat(b) + 0.5).toInt();
      } else {
        return a.compareTo(b);
      }
    });

    return files;
  }

  void onItemTap(String item) {
    final directory = Directory(item);
    final chosenJson = File(path.join(directory.path, 'info.bin'));
    final newJson = File(path.join(directory.path, 'info.json'));

    if (chosenJson.existsSync()) {
      callDownloadFragment(chosenJson);
    } else if (newJson.existsSync()) {
      callDownloadFragment(newJson, true);
    } else if (directory.existsSync()) {
      callSelf(path.basename(directory.path), directory);
    } else if (item.endsWith('.zip')) {
      FlutterToast.showToast(msg: '加载中...');
      // Implement Reader.viewOldMangaZipFile logic here
    }
  }

  void onItemLongPress(String item) {
    final directory = Directory(item);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(Icons.info),
          title: Text('提示'),
          content: Text('删除?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (directory.existsSync()) {
                  directory.deleteSync(recursive: true);
                  initScan();
                }
              },
              child: Text('确定'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
          ],
        );
      },
    );
  }

  void callDownloadFragment(File jsonFile, [bool isNew = false]) {
    final bundle = {};
    if (isNew) {
      bundle['loadJson'] = jsonFile.readAsStringSync();
    } else {
      bundle['callFromOldDL'] = true;
    }
    bundle['name'] = path.basename(jsonFile.parent.path);
    // Implement Navigate.safeNavigateTo logic here
  }

  void callSelf(String title, Directory file) {
    final bundle = {'title': title, 'file': file.path};
    // Implement Navigate.safeNavigateTo logic here
  }

  double getFloat(String oldString) {
    final newString = StringBuffer();
    final matcher = RegExp(r'\d+.\d+').allMatches(oldString);
    for (final match in matcher) {
      newString.write(match.group(0)!);
    }
    if (newString.isEmpty) {
      final matcher = RegExp(r'\d').allMatches(oldString);
      for (final match in matcher) {
        newString.write(match.group(0)!);
      }
    }
    return newString.isEmpty ? 0.0 : double.parse(newString.toString());
  }

  void removeAllEmpty() {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync().where((f) => f is Directory).toList();
    var removed = false;
    for (final file in files) {
      if (file.existsSync()) {
        file.deleteSync(recursive: true);
        removed = true;
      }
    }
    if (removed) {
      initScan();
    }
  }
}


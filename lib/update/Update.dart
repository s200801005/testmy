import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Update {
  static Future<void> checkUpdate(BuildContext context, UITools toolsBox, {bool ignoreSkip = false}) async {
    final client = Client("reilia.fumiama.top", 13212);
    final kanban = SimpleKanban(client, "fumiama");

    final progressBar = ProgressBar();
    final progressHandler = ProgressHandler(progressBar);

    final msg = await message(kanban);
    if (msg == "null") {
      if (ignoreSkip) {
        await showToast("无更新");
      }
      return;
    }

    final verNum = int.tryParse(msg.split('\n').first);
    final skipNum = await getSkipVersion();
    print("Ver:$verNum, skip: $skipNum");
    if (verNum == null) return;

    if (!msg.contains("md5:")) {
      await toolsBox.buildInfo("看板", msg.split('\n').skip(1).join('\n'), "知道了");
      return;
    }
    if (skipNum < verNum || ignoreSkip) {
      await toolsBox.buildInfo("看板", msg.split('\n').skip(1).take(msg.split('\n').length - 2).join('\n'), "下载新版", "跳过该版", "取消", () async {
        final info = toolsBox.buildAlertWithView("下载进度", progressBar, "隐藏");
        client.progress = progressHandler;
        await fetch(client, kanban, context, (data) async {
          final md5 = msg.split('md5:').last;
          if (md5 == md5Hash(data)) {
            await showToast("下载成功");
            info.dismiss();
            await install(data, context);
          } else {
            await showToast("文件损坏");
            info.dismiss();
          }
          client.progress = null;
        });
      }, () async {
        await setSkipVersion(verNum);
      });
    }
  }

  static Future<String> message(SimpleKanban kanban) async {
    return await kanban.getMessage();
  }

  static Future<void> fetch(Client client, SimpleKanban kanban, BuildContext context, Function(Uint8List) doOnLoadSuccess) async {
    try {
      final data = await kanban.fetchRaw();
      doOnLoadSuccess(data);
    } catch (e) {
      await downloadFail(client, context);
    }
  }

  static Future<void> downloadFail(Client client, BuildContext context) async {
    await showToast("下载APK失败");
    client.progress = null;
  }

  static Future<void> install(Uint8List data, BuildContext context) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/new.apk');
    await file.writeAsBytes(data);

    final intent = Intent(Intent.ACTION_VIEW);
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    if (Platform.isAndroid) {
      intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
      final contentUri = FileProvider.getUriForFile(context, "${await getPackageName()}.fileprovider", file);
      intent.setDataAndType(contentUri, "application/vnd.android.package-archive");
    } else {
      intent.setDataAndType(Uri.fromFile(file), "application/vnd.android.package-archive");
    }
    await startActivity(intent);
  }

  static Future<int> getSkipVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("skipVersion") ?? 0;
  }

  static Future<void> setSkipVersion(int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("skipVersion", version);
  }

  static String md5Hash(Uint8List data) {
    return md5.convert(data).toString();
  }

  static Future<void> showToast(String message) async {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  static Future<String> getPackageName() async {
    return await const MethodChannel('com.example.app/package_name').invokeMethod('getPackageName');
  }
}

class Client {
  final String host;
  final int port;
  ProgressHandler? progress;

  Client(this.host, this.port);
}

class SimpleKanban {
  final Client client;
  final String name;

  SimpleKanban(this.client, this.name);

  Future<String> getMessage() async {
    // Implementation
  }

  Future<Uint8List> fetchRaw() async {
    // Implementation
  }
}

class ProgressHandler {
  final ProgressBar progressBar;

  ProgressHandler(this.progressBar);

  void notify(int progressPercentage) {
    print("Set progress: $progressPercentage");
    progressBar.progress = progressPercentage;
  }
}

class ProgressBar {
  int progress = 0;
}

class UITools {
  Future<void> buildInfo(String title, String message, String actionText) async {
    // Implementation
  }

  AlertDialog buildAlertWithView(String title, ProgressBar progressBar, String actionText) {
    // Implementation
  }
}


// Dart code for a Flutter application
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

abstract class Comandy {
  // Future<String?> addDns(String? para, int isIpv6);

  Future<String?> request(String para);

  static final AtomicBoolean isInInit = AtomicBoolean(false);
  static Comandy? _instance;

  static Comandy? get instance {
    // print("get instance: $_instance");
    if (_instance != null) return _instance;
    _instance = _loadLibrary();
    // print("init instance: $_instance");
    return _instance;
  }

  static bool? _useComandy;
  static bool get useComandy {
    if (isInInit.value) {
      print("block useComandy for isInInit");
      return false;
    }
    if (_useComandy != true && DownloadTools.failTimes.value >= 2) {
      _useComandy = true;
      return true;
    }
    if (_useComandy != null) return _useComandy!;
    final mainActivity = MainActivity.mainWeakReference?.value;
    if (mainActivity != null) {
      final prefs = await SharedPreferences.getInstance();
      final useComandyPreference = prefs.getBool("settings_cat_net_sw_use_comandy") ?? false;
      print("use comandy: $useComandyPreference");
      _useComandy = useComandyPreference;
      return useComandyPreference;
    }
    _useComandy = false;
    return false;
  }

  static File? get _libraryFile {
    if (isInInit.value) return null;
    isInInit.value = true;
    print("start to download/check lib");
    String? prefix;
    final supportedAbis = Platform.isAndroid ? ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86'] : [];
    if (supportedAbis.isNotEmpty) {
      prefix = supportedAbis.firstWhere((abi) => abi == "arm64-v8a" || abi == "armeabi-v7a" || abi == "x86_64" || abi == "x86", orElse: () => null);
    } else {
      return null;
    }
    print("arch: $prefix");
    final mainActivity = MainActivity.mainWeakReference?.value;
    if (mainActivity != null) {
      var dir = Directory('${mainActivity.filesDir.path}/libs');
      if (!dir.existsSync()) dir.createSync();
      var file = File('${dir.path}/libcomandy.so');
      int remoteVersion = 0;
      if (file.existsSync()) {
        final data = await DownloadTools.getHttpContent(mainActivity.getString(R.string.comandy_version_url), -1);
        if (data != null) {
          try {
            final body = json.decode(utf8.decode(data))['body'];
            if (body != null && body.startsWith("Version: ")) {
              remoteVersion = int.parse(body.substring(9));
            }
          } catch (e) {
            print(e);
          }
          final myVersion = await prefs.getInt("comandy_version") ?? 0;
          if (myVersion >= remoteVersion) {
            print("lib version $myVersion is latest");
            isInInit.value = false;
            return file;
          }
          print("lib version $myVersion <= latest $remoteVersion, update...");
        }
      }
      final data = await DownloadTools.getHttpContent(mainActivity.getString(R.string.comandy_download_url).replaceAll("%s", prefix!), -1);
      if (file.existsSync()) file.deleteSync();
      try {
        final dataIn = GZIPDecoder().decodeBytes(data);
        file.writeAsBytesSync(dataIn);
        if (remoteVersion > 0) {
          await prefs.setInt("comandy_version", remoteVersion);
        }
        print("update success");
        isInInit.value = false;
      } catch (e) {
        print(e);
        if (file.existsSync()) file.deleteSync();
      }
      return file.existsSync() ? file : null;
    }
    return null;
  }

  static Comandy? _loadLibrary() {
    // Implement library loading logic here
    return null;
  }
}

class AtomicBoolean {
  bool value;

  AtomicBoolean(this.value);
}
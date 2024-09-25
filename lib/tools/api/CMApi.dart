// Translated from Kotlin to Dart
// Framework: Flutter

import 'package:flutter/material.dart';

import '../../0main.dart';
import '../http/Proxy.dart';
import '../http/Resolution.dart';

class CMApi {
  static Proxy? _imageProxy;
  static Proxy? _apiProxy;
  static Resolution resolution = Resolution(Regex(r'c\d+x\.'));
  static LazyHeaders? _myGlideHeaders;
  static String _myHostApiUrl = "";

  static Proxy? get imageProxy {
    if (_imageProxy != null) return _imageProxy;
    if (Proxy.useImageProxy) {
      _imageProxy = Proxy(
        R.string.imgProxyApiUrl,
        Regex(r'^https://[0-9a-z-]+\.mangafun[a-z]\.(xyz|fun)/'),
        R.string.imgProxyKeyID,
      );
    }
    return _imageProxy;
  }

  static Proxy? get apiProxy {
    if (_apiProxy != null) return _apiProxy;
    if (Proxy.useApiProxy) {
      _apiProxy = Proxy(
        R.string.apiProxyApiUrl,
        Regex(r'^https://api\.(copymanga|mangacopy)\.\w+/api/'),
        R.string.imgProxyKeyID,
      );
    }
    return _apiProxy;
  }

  static LazyHeaders? get myGlideHeaders {
    final mainActivity = MainActivity.mainWeakReference?.get();
    if (mainActivity != null) {
      final preferences = PreferenceManager.getDefaultSharedPreferences(mainActivity);
      if (_myGlideHeaders == null) {
        _myGlideHeaders = LazyHeaders.Builder()
            .addHeader("referer", DownloadTools.referer)
            .addHeader("User-Agent", DownloadTools.pc_ua)
            .addHeader("source", "copyApp")
            .addHeader("webp", "1")
            .addHeader("version", DownloadTools.app_ver)
            .addHeader("region", preferences.getBoolean("settings_cat_net", false) ? "0" : "1")
            .addHeader("platform", "3")
            .build();
      }
    }
    return _myGlideHeaders;
  }

  static String get myHostApiUrl {
    if (_myHostApiUrl.isNotEmpty) return _myHostApiUrl;
    final mainActivity = MainActivity.mainWeakReference?.get();
    if (mainActivity != null) {
      final preferences = PreferenceManager.getDefaultSharedPreferences(mainActivity);
      final host = preferences.getString("settings_cat_net_et_api_url", "");
      if (host != null && host.isNotEmpty) {
        _myHostApiUrl = host;
        return host;
      }
      _myHostApiUrl = mainActivity.getString(R.string.hostUrl);
    }
    return _myHostApiUrl;
  }

  static File getZipFile(Directory? exDir, String manga, String caption, String name) {
    return File('${exDir?.path}/$manga/$caption/$name.zip');
  }

  static String? getChapterInfoApiUrl(String? arg1, String? arg2) {
    return MainActivity.mainWeakReference?.get()?.getString(R.string.chapterInfoApiUrl)
        ?.replaceAll('%s', myHostApiUrl)
        .replaceAll('%s', arg1 ?? '')
        .replaceAll('%s', arg2 ?? '');
  }
}
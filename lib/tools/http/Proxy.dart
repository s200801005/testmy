// Translated from Kotlin to Dart
// Framework: Flutter

import 'dart:convert';
import 'package:flutter/material.dart';

import '../../0main.dart';

class Proxy {
  final int id;
  final RegExp apiRegex;
  final int? keyID;

  String? code;
  String? proxyApiUrl;

  Proxy(this.id, this.apiRegex, [this.keyID]) {
    code = keyID != null
        ? MainActivity.mainWeakReference?.value
            ?.getString(keyID.toString()) // Assuming a method to get string by key
        : null;
    proxyApiUrl = MainActivity.mainWeakReference?.value?.getString(id.toString());
  }

  String wrap(String u) {
    if (!apiRegex.hasMatch(u)) {
      debugPrint("[N] wrap: $u");
      return u;
    }
    if (code != null && code!.isNotEmpty) {
      String wu = proxyApiUrl != null
          ? proxyApiUrl!.replaceAll('%s', code!).replaceAll('%u', Uri.encodeComponent(u))
          : u;
      debugPrint("[M] wrap: $wu");
      return wu;
    }
    debugPrint("[C] wrap: $u");
    return u;
  }

  static bool? _mUseImageProxy;
  static bool get useImageProxy {
    if (_mUseImageProxy != null) return _mUseImageProxy!;
    MainActivity.mainWeakReference?.value?.let((context) {
      bool b = context.getBoolean("settings_cat_net_sw_use_img_proxy", false);
      debugPrint("use image proxy: $b");
      _mUseImageProxy = b;
      return b;
    });
    _mUseImageProxy = false;
    return false;
  }

  static bool? _mUseApiProxy;
  static bool get useApiProxy {
    if (_mUseApiProxy != null) return _mUseApiProxy!;
    MainActivity.mainWeakReference?.value?.let((context) {
      bool b = context.getBoolean("settings_cat_net_sw_use_api_proxy", false);
      debugPrint("use api proxy: $b");
      _mUseApiProxy = b;
      return b;
    });
    _mUseApiProxy = false;
    return false;
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UITools {
  final BuildContext? context;
  final WeakReference<State>? weak;

  UITools(this.context, [this.weak]);

  UITools.fromWeak(WeakReference<State> weak)
      : this(weak.target?.context, weak);

  String get transportStringNull =>
      context?.localizations?.transportStringNull ?? "TRANSPORT_NULL";
  String get transportStringError =>
      context?.localizations?.transportStringError ?? "TRANSPORT_ERROR";

  String get netInfo {
    final cm = Connectivity();
    final connectivityResult = await cm.checkConnectivity();
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return context?.localizations?.transportWifi ?? "TRANSPORT_WIFI";
      case ConnectivityResult.mobile:
        return context?.localizations?.transportCellular ?? "TRANSPORT_CELLULAR";
      case ConnectivityResult.bluetooth:
        return context?.localizations?.transportBluetooth ?? "TRANSPORT_BLUETOOTH";
      case ConnectivityResult.ethernet:
        return context?.localizations?.transportEthernet ?? "TRANSPORT_ETHERNET";
      case ConnectivityResult.vpn:
        return "VPN";
      default:
        return transportStringNull;
    }
  }

  Future<void> toastError(String s, {bool willFinish = true}) async {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(content: Text(s)),
    );
    if (willFinish) {
      Navigator.of(context!).pop();
    }
  }

  Future<void> toastError(int s, {bool willFinish = true}) async {
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(content: Text(s.toString())),
    );
    if (willFinish) {
      Navigator.of(context!).pop();
    }
  }

  void buildInfo({
    required String title,
    required String msg,
    String? txtOk,
    String? txtN,
    String? txtCancel,
    VoidCallback? ok,
    VoidCallback? neutral,
    VoidCallback? cancel,
  }) {
    showDialog(
      context: context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            if (txtOk != null)
              TextButton(
                child: Text(txtOk),
                onPressed: ok,
              ),
            if (txtCancel != null)
              TextButton(
                child: Text(txtCancel),
                onPressed: cancel,
              ),
            if (txtN != null)
              TextButton(
                child: Text(txtN),
                onPressed: neutral,
              ),
          ],
        );
      },
    );
  }

  AlertDialog buildAlertWithView({
    required String title,
    required Widget view,
    String? txtOk,
    String? txtN,
    String? txtCancel,
    VoidCallback? ok,
    VoidCallback? neutral,
    VoidCallback? cancel,
  }) {
    return AlertDialog(
      title: Text(title),
      content: view,
      actions: <Widget>[
        if (txtOk != null)
          TextButton(
            child: Text(txtOk),
            onPressed: ok,
          ),
        if (txtCancel != null)
          TextButton(
            child: Text(txtCancel),
            onPressed: cancel,
          ),
        if (txtN != null)
          TextButton(
            child: Text(txtN),
            onPressed: neutral,
          ),
      ],
    );
  }

  int? dp2px(int dp) {
    final density = MediaQuery.of(context!).devicePixelRatio;
    return (dp * density + 0.5).toInt();
  }

  int? px2dp(int px) {
    final density = MediaQuery.of(context!).devicePixelRatio;
    return (px / density + 0.5).toInt();
  }

  List<int> calcWidthFromDp(int marginLeftDp, int widthDp) {
    final margin = marginLeftDp.toDouble();
    final marginPx = dp2px(marginLeftDp) ?? 16;
    final screenWidth = MediaQuery.of(context!).size.width.toInt();
    final numPerRow = ((px2dp(screenWidth) ?? 400).toDouble() / (widthDp + 2 * margin) + 0.5).toInt();
    final w = (screenWidth - marginPx * numPerRow * 2) / numPerRow;
    final totalWidth = screenWidth / numPerRow;
    return [numPerRow, w, totalWidth];
  }

  List<double>? root(double a, double b, double c) {
    final d = b * b - 4.0 * a * c;
    if (d < 0) return null;
    final sd = sqrt(d);
    final x1 = (-b + sd) / (2.0 * a);
    final x2 = (-b - sd) / (2.0 * a);
    return [x1, x2];
  }

  List<int> calcWidthFromDpRoot(int marginLeftDp, int widthDp) {
    final margin = marginLeftDp.toDouble();
    final marginPx = dp2px(marginLeftDp) ?? 16;
    final root = root(margin, widthDp.toDouble(), -((px2dp(MediaQuery.of(context!).size.width.toInt()) ?? 400).toDouble()));
    final numPerRow = root?.let((it) => (it[0] + 0.5).toInt()) ?? 3;
    final w = (MediaQuery.of(context!).size.width.toInt() - marginPx * (numPerRow + 1)) / numPerRow;
    final totalWidth = (MediaQuery.of(context!).size.width.toInt() - marginPx) / numPerRow;
    return [numPerRow, w, totalWidth];
  }

  static String toHexStr(List<int> byteArray) {
    final sb = StringBuffer();
    for (final byte in byteArray) {
      final hex = byte & 0xFF;
      final hexStr = hex.toRadixString(16);
      if (hexStr.length == 1) {
        sb.write('0');
      }
      sb.write(hexStr);
    }
    return sb.toString();
  }

  static int getNavigationBarHeight(BuildContext context) {
    final resources = MediaQuery.of(context);
    final resourceId = resources.viewInsets.bottom;
    return resourceId > 0 ? resourceId : 64;
  }

  static int getStatusBarHeight(BuildContext context) {
    final resources = MediaQuery.of(context);
    final resourceId = resources.viewPadding.top;
    return resourceId > 0 ? resourceId : 64;
  }
}


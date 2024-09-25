// This code is for a Dart application.

import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;

class PausableDownloader {
  final String url;
  final int waitMilliseconds;
  final bool isApi;
  final Future<void> Function(Uint8List result)? whenFinish;
  bool exit = false;

  PausableDownloader(this.url, {this.waitMilliseconds = 0, this.isApi = true, this.whenFinish});

  Future<bool> run() async {
    int attemptCount = 0;
    while (!exit && attemptCount++ < 3) {
      try {
        final String? wrappedUrl = isApi ? CMApi.apiProxy?.wrap(url) : null;
        final response = await DownloadTools.getHttpContent(wrappedUrl ?? url, DownloadTools.referer);
        whenFinish?.call(response);
        return true;
      } catch (e) {
        print(e); // Replace with your logging mechanism
        if (waitMilliseconds > 0) {
          await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(waitMilliseconds)));
        }
      }
    }
    print('found exit = $exit'); // Replace with your logging mechanism
    return false;
  }
}
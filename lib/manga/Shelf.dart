// Translated from Kotlin to Dart
// This code uses the Dart programming language and is intended for Flutter or Dart-based applications.

import 'package:gson/gson.dart'; // Assuming a Gson-like library is available in Dart
import 'package:your_app/api/cm_api.dart'; // Adjust the import based on your project structure
import 'package:your_app/tools/download_tools.dart'; // Adjust the import based on your project structure

class Shelf {
  final String token;
  final String hostUrl;
  final String apiUrl;
  final String queryApiUrlTemplate;
  final String referer;

  Shelf(this.token, String Function(int) getString)
      : hostUrl = getString(R.string.hostUrl),
        apiUrl = getString(R.string.shelfOperateApiUrl).replaceAll('%s', hostUrl),
        queryApiUrlTemplate = getString(R.string.bookUserQueryApiUrl),
        referer = getString(R.string.referer).replaceAll('%s', DownloadTools.app_ver);

  String get addApiUrl => '${apiUrl}?platform=3'..let((it) => CMApi.apiProxy?.wrap(it) ?? it);
  String get delApiUrl => '${apiUrl}s?platform=3'..let((it) => CMApi.apiProxy?.wrap(it) ?? it);

  Future<String> add(String comicId) async {
    if (comicId.isEmpty) {
      return '空漫画ID';
    }
    final String body = 'comic_id=$comicId&is_collect=1&authorization=Token+${token}';
    final String? response = await DownloadTools.requestWithBody(
      addApiUrl, 'POST', body.codeUnits
    )?.decodeToString();
    if (response == null) {
      return '空回应';
    }
    try {
      return Gson().fromJson(response, ReturnBase).message;
    } catch (e) {
      return '$response ${e.message}';
    }
  }

  Future<String> del(List<int> bookIds) async {
    if (bookIds.isEmpty) {
      return '空ID列表';
    }
    final String body = bookIds.map((id) => 'ids=$id').join('&') + '&authorization=Token+$token';
    final String? response = await DownloadTools.requestWithBody(
      delApiUrl, 'DELETE', body.codeUnits
    )?.decodeToString();
    if (response == null) {
      return '空回应';
    }
    try {
      return Gson().fromJson(response, ReturnBase).message;
    } catch (e) {
      return '$response ${e.message}';
    }
  }

  Future<BookQueryStructure?> query(String pathWord) async {
    try {
      final String url = queryApiUrlTemplate.replaceAll('%s', hostUrl).replaceAll('%s', pathWord);
      final String? content = await DownloadTools.getHttpContent(
        CMApi.apiProxy?.wrap(url) ?? url, referer
      )?.decodeToString();
      return Gson().fromJson(content, BookQueryStructure);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
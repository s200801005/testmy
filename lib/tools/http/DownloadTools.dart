import 'dart:convert';
import 'dart:convert' show base64Decode, jsonDecode, jsonEncode, utf8;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'Comandy.dart';

class DownloadTools {
  static const String appVer = "1.0.0"; // 替换为实际版本号
  static const String pcUa = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36";
  static const String referer = "https://example.com";
  static int failTimes = 0;

  static Future<http.Client> getApiConnection(String url,
      {String method = "GET",
      String refer = "",
      String ua = "",
      int timeout = 20000}) async {
    final client = http.Client();
    final headers = {
      "host": url.substring(url.indexOf("//") + 2).split("/")[0],
      "user-agent": ua ?? pcUa,
      "referer": refer ?? referer,
      "source": "copyApp",
      "webp": "1",
      "region": "1", // 假设默认值
      "version": appVer,
      "platform": "3"
    };

    return client;
  }

  static Future<Map<String, dynamic>> getComandyApiConnection(String url,
      {String method = "GET",
      String refer = "",
      String ua = ""}) async {
    final capsule = {
      "url": url,
      "method": method,
      "headers": {
        "host": url.substring(url.indexOf("//") + 2).split("/")[0],
        "user-agent": ua ?? pcUa,
        "referer": refer ?? referer,
        "source": "copyApp",
        "webp": "1",
        "region": "1", // 假设默认值
        "version": appVer,
        "platform": "3"
      }
    };

    return capsule;
  }

  static Future<List<int>> getHttpContent(String url,
      {String refer = "", String ua = pcUa, required int readSize}) async {
    if (!url.startsWith("https://copymanga.azurewebsites.net") && Comandy.useComandy) {
      final capsule = await getComandyApiConnection(url, method: "GET", refer: refer, ua: ua);
      final para = jsonEncode(capsule);
      final response = await Comandy.instance?.request(para);
      if (response != null) {
        final decodedResponse = jsonDecode(response);
        if (decodedResponse['code'] == 200) {
          final data = decodedResponse['data'];
          if (data != null) {
            return base64Decode(data);
          }
        }
      }
    }

    failTimes++;
    final response = await http.get(Uri.parse(url),
        headers: {
          "host": url.substring(url.indexOf("//") + 2).split("/")[0],
          "user-agent": ua ?? pcUa,
          "referer": refer ?? referer
        });

    failTimes--;
    return response.bodyBytes;
  }

  static Future<List<int>?> getHttpContentWithReadSize(String url, int readSize) async {
    final task = getHttpContent(url, readSize: readSize);
    try {
      return await task;
    } catch (ex) {
      print(ex);
      if (Comandy.useComandy) {
        failTimes++;
      }
      return null;
    }
  }

  static Future<List<int>?> prepare(String url, int readSize) async {
    if (!url.startsWith("https://copymanga.azurewebsites.net") && Comandy.useComandy) {
      try {
        final capsule = await getComandyNormalConnection(url, method: "GET", ua: pcUa);
        final response = await Comandy.instance?.request(jsonEncode(capsule));
        final decodedResponse = jsonDecode(response!);
        if (decodedResponse['code'] == 200) {
          final data = decodedResponse['data'];
          if (data != null) {
            return base64Decode(data);
          }
        }
      } catch (ex) {
        print(ex);
      }
    }

    try {
      final response = await http.get(Uri.parse(url),
          headers: {
            "host": url.substring(url.indexOf("//") + 2).split("/")[0],
            "user-agent": pcUa
          });

      if (readSize > 0) {
        final bytes = List<int>.filled(readSize, 0);
        response.bodyBytes.asMap().forEach((index, byte) {
          if (index < readSize) {
            bytes[index] = byte;
          }
        });
        return bytes;
      } else {
        return response.bodyBytes;
      }
    } catch (ex) {
      print(ex);
      return null;
    }
  }

  static Future<List<int>> requestWithBody(String url, String method, List<int> body,
      {String refer = referer, String ua = pcUa, String contentType = "application/x-www-form-urlencoded;charset=utf-8"}) async {
    if (!url.startsWith("https://copymanga.azurewebsites.net") && Comandy.useComandy) {
      try {
        final capsule = await getComandyApiConnection(url, method: method, refer: refer, ua: ua);
        capsule['headers']['content-type'] = contentType;
        capsule['data'] = utf8.decode(body);
        final response = await Comandy.instance?.request(jsonEncode(capsule));
        final decodedResponse = jsonDecode(response!);
        if (decodedResponse['code'] == 200) {
          final data = decodedResponse['data'];
          if (data != null) {
            return base64Decode(data);
          }
        }
      } catch (ex) {
        print(ex);
      }
    }

    failTimes++;
    final response = await http.post(Uri.parse(url),
        body: body,
        headers: {
          "host": url.substring(url.indexOf("//") + 2).split("/")[0],
          "user-agent": ua ?? pcUa,
          "referer": refer ?? referer,
          "content-type": contentType
        });

    failTimes--;
    return response.bodyBytes;
  }

  static getComandyNormalConnection(String url, {required String method, required String ua}) {}
}




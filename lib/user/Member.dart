import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:base64/base64.dart';

// 假设 `LoginInfoStructure` 和其他相关类已经定义
class LoginInfoStructure {
  int code;
  String message;
  Results results;

  LoginInfoStructure({this.code, this.message, this.results});

  factory LoginInfoStructure.fromJson(Map<String, dynamic> json) {
    return LoginInfoStructure(
      code: json['code'],
      message: json['message'],
      results: json['results'] != null ? Results.fromJson(json['results']) : null,
    );
  }
}

class Results {
  String token;
  String userId;
  String username;
  String nickname;
  String avatar;

  Results({this.token, this.userId, this.username, this.nickname, this.avatar});

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      token: json['token'],
      userId: json['userId'],
      username: json['username'],
      nickname: json['nickname'],
      avatar: json['avatar'],
    );
  }
}

class Member {
  final SharedPreferences pref;
  final Function(int) getString;

  Member(this.pref, this.getString);

  bool get hasLogin => pref.getString("token", "").isNotEmpty ?? false;

  Future<LoginInfoStructure> login(String username, String pwd, int salt) async {
    var err = "";

    if (!Proxy.useApiProxy && Comandy.useComandy) {
      try {
        final capsule = getComandyLoginConnection(username, pwd, salt);
        final para = jsonEncode(capsule);
        final result = await Comandy.instance.request(para);
        final response = jsonDecode(result);

        if (response['code'] != 200) {
          final l = LoginInfoStructure();
          l.code = response['code'];
          l.message = Base64.decode(response['data']).decode();
          return l;
        }

        final data = Base64.decode(response['data']);
        return saveInfo(data);
      } catch (e) {
        err = e.toString();
        return null;
      }
    } else {
      try {
        final connection = getLoginConnection(username, pwd, salt);
        final data = await connection.readBytes();
        return saveInfo(data);
      } catch (e) {
        err = e.toString();
      }
    }

    final l = LoginInfoStructure();
    l.code = 400;
    l.message = err;
    return l;
  }

  Future<LoginInfoStructure> info() async {
    if (!pref.containsKey("token")) {
      final l = LoginInfoStructure();
      l.code = 449;
      l.message = getString(R.string.noLogin);
      return l;
    }

    try {
      final url = getString(R.string.memberInfoApiUrl).replaceFirst(CMApi.myHostApiUrl, "");
      final wrappedUrl = CMApi.apiProxy?.wrap(url) ?? url;
      final response = await http.get(Uri.parse(wrappedUrl));
      final data = jsonDecode(utf8.decode(response.bodyBytes));

      final l = LoginInfoStructure.fromJson(data);
      if (l.code == 200) {
        pref.edit()
          ..putString("avatar", l.results.avatar)
          ..apply();
      }

      return l;
    } catch (e) {
      final l = LoginInfoStructure();
      l.code = 450;
      l.message = "${getString(R.string.login_get_avatar_failed)}: $e";
      return l;
    }
  }

  Future<void> logout() async {
    pref.edit()
      ..remove("token")
      ..remove("user_id")
      ..remove("username")
      ..remove("nickname")
      ..remove("avatar")
      ..apply();
  }

  Future<LoginInfoStructure> saveInfo(List<int> data) async {
    try {
      final l = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      final loginInfo = LoginInfoStructure.fromJson(l);

      if (loginInfo.code == 200) {
        pref.edit()
          ..putString("token", loginInfo.results.token)
          ..putString("user_id", loginInfo.results.userId)
          ..putString("username", loginInfo.results.username)
          ..putString("nickname", loginInfo.results.nickname)
          ..apply();

        return info();
      }

      return loginInfo;
    } catch (e) {
      throw Exception(getString(R.string.login_parse_json_error), e);
    }
  }

  String getLoginConnection(String username, String pwd, int salt) {
    final apiUrl = getString(R.string.loginApiUrl).replaceFirst(CMApi.myHostApiUrl, "");
    final wrappedUrl = CMApi.apiProxy?.wrap(apiUrl) ?? apiUrl;

    final pwdEncoded = base64Encode(utf8.encode("$pwd-$salt"));
    final params = {
      "username": Uri.encodeComponent(username),
      "password": pwdEncoded,
      "salt": salt,
      "platform": "3",
      "authorization": "Token",
      "version": app_ver,
      "source": "copyApp",
      "region": pref.getBoolean("settings_cat_net_sw_use_foreign", false) ? "1" : "0",
      "webp": "1"
    };

    final body = params.entries.map((entry) => "${entry.key}=${entry.value}").join("&");

    return wrappedUrl;
  }

  String getComandyLoginConnection(String username, String pwd, int salt) {
    final apiUrl = getString(R.string.loginApiUrl).replaceFirst(CMApi.myHostApiUrl, "");
    final wrappedUrl = CMApi.apiProxy?.wrap(apiUrl) ?? apiUrl;

    final pwdEncoded = base64Encode(utf8.encode("$pwd-$salt"));
    final headers = {
      "content-type": "application/x-www-form-urlencoded;charset=utf-8",
      "platform": "3",
      "accept": "application/json"
    };

    final params = {
      "username": Uri.encodeComponent(username),
      "password": pwdEncoded,
      "salt": salt,
      "platform": "3",
      "authorization": "Token",
      "version": app_ver,
      "source": "copyApp",
      "region": pref.getBoolean("settings_cat_net_sw_use_foreign", false) ? "1" : "0",
      "webp": "1"
    };

    final body = params.entries.map((entry) => "${entry.key}=${entry.value}").join("&");

    return wrappedUrl;
  }
}

// Translated from Kotlin to Dart for a Flutter application

import 'package:flutter/material.dart';
import 'package:your_package_name/api/cm_api.dart'; // Adjust the package name according to your structure
import 'package:your_package_name/main_activity.dart'; // Adjust the package name according to your structure
import 'package:your_package_name/ui/info_card_loader.dart'; // Adjust the package name according to your structure
import 'package:your_package_name/localization/strings.dart';

import '../../../0main.dart';
import '../../../template/ui/InfoCardLoader.dart'; // Adjust the package name according to your structure

class HistoryFragment extends InfoCardLoader {
  HistoryFragment() : super(fragmentLayout: R.layout.fragment_history, actionId: R.id.action_nav_history_to_nav_book, isHistoryBook: true);

  String getApiUrl() {
    return strings.historyApiUrl.format(CMApi.myHostApiUrl, page * 21);
  }

  @override
  void onCreate(BuildContext context) {
    if (MainActivity.member?.hasLogin != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.noLogin)),
      );
      Navigator.of(context).pop();
    }
    super.onCreate(context);
  }
}
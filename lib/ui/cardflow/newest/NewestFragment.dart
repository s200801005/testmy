// Translated from Kotlin to Dart
// Using Flutter framework

import 'package:flutter/material.dart';
import 'package:your_package_name/info_card_loader.dart'; // Adjust the import according to your project structure
import 'package:your_package_name/cm_api.dart'; // Adjust the import according to your project structure
import 'package:your_package_name/resources.dart'; // Adjust the import according to your project structure

class NewestFragment extends InfoCardLoader {
  NewestFragment() : super('fragment_newest', 'action_nav_newest_to_nav_book', true);

  @override
  String getApiUrl() {
    return '${getString(Resources.newestApiUrl)}'.replaceAll('%s', CMApi.myHostApiUrl) + (page * 21).toString();
  }
}
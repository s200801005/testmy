// This code is translated from Kotlin to Dart using Flutter framework

import 'package:flutter/material.dart';
import 'package:your_package_name/api/cm_api.dart'; // Replace with actual package name
import 'package:your_package_name/template/info_card_loader.dart'; // Replace with actual package name
import 'package:your_package_name/resources/resources.dart'; // Replace with actual package name

class RecommendationFragment extends InfoCardLoader {
  RecommendationFragment()
      : super(fragmentRecommendLayout, actionNavRecommendToNavBook, true);

  @override
  String getApiUrl() {
    return getString(recommendApiUrl).replaceAll('%s', CMApi.myHostApiUrl).replaceAll('%d', (page * 21).toString());
  }
}
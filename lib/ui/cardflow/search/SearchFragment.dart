// Translated from Kotlin to Dart for Flutter framework.
import 'package:flutter/material.dart';
import 'package:my_app/api/cm_api.dart'; // Assume this is the correct import for CMApi
import 'package:my_app/ui/info_card_loader.dart'; // Assume this is the correct import for InfoCardLoader

class SearchFragment extends InfoCardLoader {
  String? query;
  String? type;

  SearchFragment() : super(fragmentSearchLayout, actionNavSearchToNavBook);

  String getApiUrl() {
    return '${CMApi.myHostApiUrl}/${(page * 21)}/$query/$type'; // Adjusted to match Dart syntax
  }

  @override
  void onCreate(BuildContext context) {
    super.onCreate(context);
    if (isFirstInflate) {
      query = ModalRoute.of(context)!.settings.arguments['query'] as String?;
      type = ModalRoute.of(context)!.settings.arguments['type'] as String?;
      debugPrint('MySF: get query=$query, type=$type');
    }
  }
}
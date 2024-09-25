// Translated from Kotlin to Dart
// Flutter framework

import 'package:flutter/material.dart';

class FinishFragment extends StatusCardFlow {
  FinishFragment()
      : super(
            finishApiUrl: 'R.string.finishApiUrl',
            actionId: 'R.id.action_nav_finish_to_nav_book',
            layoutId: 'R.layout.fragment_statuscardflow');

  @override
  void onViewCreated(View view, Bundle? savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    lineUpdate = lineFinishTime; // line_finish_time
    lineHot = lineFinishPop; // line_finish_pop
  }
}
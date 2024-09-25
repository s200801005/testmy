// Flutter framework
import 'package:flutter/material.dart';

class ThemeCardFlow extends StatusCardFlow {
  final int api;
  String theme = "";

  ThemeCardFlow(this.api, int nav) : super(0, nav, R.layout.fragment_statuscardflow);

  String getApiUrl() {
    return getString(api).format(
      CMApi.myHostApiUrl,
      page * 21,
      sortWay[sortValue],
      theme,
    );
  }

  @override
  void onCreate(Bundle? savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (arguments != null) {
      theme = arguments?.getString("path") ?? "";
      String? name = arguments?.getString("name");
      if (name != null) {
        activity?.toolbar?.title = name;
      }
    }
  }

  @override
  void onViewCreated(View view, Bundle? savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    lineUpdate = line_finish_time;
    lineHot = line_finish_pop;
  }

  @override
  void onResume() {
    super.onResume();
    String? name = arguments?.getString("name");
    if (name != null) {
      activity?.toolbar?.title = name;
    }
  }
}
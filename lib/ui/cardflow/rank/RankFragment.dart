// Translated from Kotlin to Dart for Flutter framework
import 'package:flutter/material.dart';
import 'package:your_project_name/api/cm_api.dart';
import 'package:your_project_name/ui/info_card_loader.dart';
import 'package:your_project_name/tools/ui_tools.dart';
import 'package:your_project_name/resources/string_resources.dart';

class RankFragment extends InfoCardLoader {
  final List<String> sortWays = ["day", "week", "month", "total"];
  int sortValue = 0;
  final List<String> audienceWays = ["", "male", "female"];
  int audience = 0; // 0 all 1 male 2 female
  bool isLoading = false;

  RankFragment() : super(fragmentLayoutId: R.layout.fragment_rank, actionId: R.id.action_nav_rank_to_nav_book, isTypeBook: true);

  @override
  void onCreate(BuildContext context) {
    super.onCreate(context);
    wr = WeakReference(this);
  }

  @override
  void onPause() {
    super.onPause();
    wr = null;
    ad?.exit = true;
  }

  @override
  void onResume() {
    super.onResume();
    wr = WeakReference(this);
    ad?.exit = false;
  }

  @override
  void onDestroy() {
    super.onDestroy();
    wr = null;
    ad?.exit = true;
  }

  @override
  Future<void> onLoadFinish() async {
    super.onLoadFinish();
    isLoading = false;
  }

  @override
  String getApiUrl() {
    return StringResources.rankApiUrl.format(
      CMApi.myHostApiUrl,
      page * 21,
      sortWays[sortValue],
      audienceWays[audience],
    );
  }

  @override
  void setListeners() {
    super.setListeners();
    frlai.lrt.post(() {
      frlai.lrt.addTabSelectedListener((tab) {
        if (tab != null) {
          sortValue = tab.position;
          if (!isLoading) {
            isLoading = true;
            delayedRefresh(400);
          }
        }
      });
    });
  }

  void showSexInfo(UITools toolsBox) {
    if (ad?.exit == true) return;
    toolsBox.buildInfo(
      "切换类型",
      "选择一种想筛选的漫画类型",
      "男频",
      "全部",
      "女频",
      () {
        if (!isLoading) {
          audience = 1;
          isLoading = true;
          delayedRefresh(400);
        }
      },
      () {
        if (!isLoading) {
          audience = 0;
          isLoading = true;
          delayedRefresh(400);
        }
      },
      () {
        if (!isLoading) {
          audience = 2;
          isLoading = true;
          delayedRefresh(400);
        }
      },
    );
  }

  static WeakReference<RankFragment>? wr;
}
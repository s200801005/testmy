// This code is translated from Kotlin to Dart.
// The translation assumes a Flutter framework for UI components.

import 'package:flutter/material.dart';
import 'package:your_package/api/cm_api.dart'; // Replace with actual import
import 'package:your_package/strings.dart'; // Replace with actual import

@ExperimentalStdlibApi
class StatusCardFlow extends InfoCardLoader {
  final int apiEndpoint;
  final List<String> sortingOptions = ["-datetime_updated", "datetime_updated", "-popular", "popular"];
  int currentSortValue = 0;
  Widget? updateLine;
  Widget? hotLine;

  StatusCardFlow({
    required this.apiEndpoint,
    required int navigation,
    required int inflateResource,
    bool isBookType = false,
    bool isHistoryBook = false,
    bool isShelfBook = false,
  }) : super(inflateResource, navigation, isBookType, isHistoryBook, isShelfBook);

  String getApiUrl() {
    return getString(apiEndpoint).format(
      CMApi.myHostApiUrl,
      page * 21,
      sortingOptions[currentSortValue],
    );
  }

  void setListeners() {
    super.setListeners();
    updateLine?.post(() {
      setUpdate(updateLine!);
      updateLine!.alpha = 1.0;
    });
    hotLine?.post(() {
      setHot(hotLine!);
      hotLine!.alpha = 0.5;
    });
  }

  void setUpdate(Widget line) {
    line.apply(() {
      apt.setText(R.string.menu_update_time);
      setOnClickListener(() {
        currentSortValue = triggerLine(false);
        delayedRefresh(400);
      });
    });
  }

  void setHot(Widget line) {
    line.apply(() {
      apt.setText(R.string.menu_hot);
      setOnClickListener(() {
        currentSortValue = triggerLine(true);
        delayedRefresh(400);
      });
    });
  }

  int triggerLine(bool isHot) {
    final Widget hot = hotLine ?? return 0;
    final Widget update = updateLine ?? return 0;

    if (currentSortValue >= 2) {
      if (isHot) {
        if (hot.apim.rotation == 0.0) {
          ObjectAnimator.ofFloat(hot.apim, "rotation", 0.0, 180.0).setDuration(233).start();
          return 3;
        } else {
          ObjectAnimator.ofFloat(hot.apim, "rotation", 180.0, 0.0).setDuration(233).start();
          return 2;
        }
      } else {
        update.alpha = 1.0;
        hot.alpha = 0.5;
        return update.apim.rotation == 0.0 ? 0 : 1;
      }
    } else {
      if (!isHot) {
        if (update.apim.rotation == 0.0) {
          ObjectAnimator.ofFloat(update.apim, "rotation", 0.0, 180.0).setDuration(233).start();
          return 1;
        } else {
          ObjectAnimator.ofFloat(update.apim, "rotation", 180.0, 0.0).setDuration(233).start();
          return 0;
        }
      } else {
        hot.alpha = 1.0;
        update.alpha = 0.5;
        return hot.apim.rotation == 0.0 ? 2 : 3;
      }
    }
  }
}
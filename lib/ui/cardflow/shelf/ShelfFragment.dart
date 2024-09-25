// Flutter framework
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class ShelfFragment extends InfoCardLoader {
  final List<String> sortOrder = [
    "-datetime_updated",
    "datetime_updated",
    "-datetime_modifier",
    "datetime_modifier",
    "-datetime_browse",
    "datetime_browse"
  ];
  int sortIndex = 0;

  ShelfFragment() : super(R.layout.fragment_shelf, R.id.action_nav_sub_to_nav_book, isShelfBook: true);

  String getApiUrl() {
    return getString(R.string.shelfApiUrl).format(
      CMApi.myHostApiUrl,
      page * 21,
      sortOrder[sortIndex]
    );
  }

  @override
  void onCreate(BuildContext context) {
    if (MainActivity.member?.hasLogin != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(R.string.noLogin))
      );
      Navigator.of(context).pop();
    }
    super.onCreate(context);
  }

  @override
  void setListeners() {
    super.setListeners();
    fade();
    setUpdate();
    setModify();
    setBrowse();
  }

  void setUpdate() {
    lineShelfUpdated.post(() {
      if (ad?.exit == true) return;
      apt.setText(R.string.menu_update_time);
      lineShelfUpdated.onClick(() {
        bool isSame = sortIndex >= 0 && sortIndex <= 1;
        sortIndex = rotate(it.apim, isSame, 0);
        if (!isSame) fade();
        delayedRefresh(400);
      });
    });
  }

  void setModify() {
    lineShelfModifier.post(() {
      if (ad?.exit == true) return;
      apt.setText(R.string.menu_add_time);
      lineShelfModifier.onClick(() {
        bool isSame = sortIndex >= 2 && sortIndex <= 3;
        sortIndex = rotate(it.apim, isSame, 2);
        if (!isSame) fade();
        delayedRefresh(400);
      });
    });
  }

  void setBrowse() {
    lineShelfBrowse.post(() {
      if (ad?.exit == true) return;
      apt.setText(R.string.menu_read_time);
      lineShelfBrowse.onClick(() {
        bool isSame = sortIndex >= 4;
        sortIndex = rotate(it.apim, isSame, 4);
        if (!isSame) fade();
        delayedRefresh(400);
      });
    });
  }

  int rotate(View img, bool isSameSlot, int offset) {
    if (isSameSlot) {
      if (img.rotation == 0.0) {
        AnimationController controller = AnimationController(duration: const Duration(milliseconds: 233), vsync: this);
        Tween<double> tween = Tween<double>(begin: 0.0, end: 180.0);
        Animation<double> animation = tween.animate(controller);
        controller.forward();
        return offset + 1;
      } else {
        AnimationController controller = AnimationController(duration: const Duration(milliseconds: 233), vsync: this);
        Tween<double> tween = Tween<double>(begin: 180.0, end: 0.0);
        Animation<double> animation = tween.animate(controller);
        controller.forward();
        return offset;
      }
    } else {
      return img.rotation == 0.0 ? offset : offset + 1;
    }
  }

  void fade() {
    List<double> alphaValues;
    switch (sortIndex) {
      case 0:
      case 1:
        alphaValues = [1.0, 0.5, 0.5];
        break;
      case 2:
      case 3:
        alphaValues = [0.5, 1.0, 0.5];
        break;
      case 4:
      case 5:
        alphaValues = [0.5, 0.5, 1.0];
        break;
      default:
        alphaValues = [1.0, 1.0, 1.0];
    }
    lineShelfUpdated.post(() => lineShelfUpdated.alpha = alphaValues[0]);
    lineShelfModifier.post(() => lineShelfModifier.alpha = alphaValues[1]);
    lineShelfBrowse.post(() => lineShelfBrowse.alpha = alphaValues[2]);
  }
}
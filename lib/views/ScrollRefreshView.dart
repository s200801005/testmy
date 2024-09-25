// Flutter framework
import 'package:flutter/material.dart';

class ScrollRefreshView extends NestedScrollView {
  ScrollRefreshView(BuildContext context) : super(key: UniqueKey(), body: Container());

  ScrollRefreshView.withAttributes(BuildContext context, {Key? key}) : super(key: key, body: Container());

  ScrollRefreshView.withAttributesAndStyle(BuildContext context, {Key? key, ScrollPhysics? physics}) 
      : super(key: key, body: Container(), physics: physics);

  SwipeRefreshLayout? swipeRefreshLayout;

  @override
  void onScrollChanged(double scrollOffset) {
    super.onScrollChanged(scrollOffset);
    if (swipeRefreshLayout?.isRefreshing == false) {
      swipeRefreshLayout?.isEnabled = scrollOffset == 0;
    }
  }
}
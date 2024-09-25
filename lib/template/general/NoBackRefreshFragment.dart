// This code is translated from Kotlin to Dart for a Flutter application.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoBackRefreshFragment extends StatefulWidget {
  final int layoutToLoad;

  NoBackRefreshFragment({required this.layoutToLoad});

  @override
  _NoBackRefreshFragmentState createState() => _NoBackRefreshFragmentState();
}

class _NoBackRefreshFragmentState extends State<NoBackRefreshFragment> {
  Widget? _rootView;
  bool isFirstInflate = true;
  double navBarHeight = 0;
  bool disableAnimation = false;
  final AtomicBoolean isHideRunning = AtomicBoolean();

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  void _initializePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    disableAnimation = prefs.getBool("settings_cat_general_sw_disable_kanban_animation") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_rootView == null) {
      isFirstInflate = true;
      _rootView = Container(); // Replace with actual layout loading logic
      print("MyNBRF: is first inflate");
    } else {
      isFirstInflate = false;
      print("MyNBRF: not first inflate");
    }
    navBarHeight = MediaQuery.of(context).padding.bottom;

    return _rootView!;
  }

  @override
  void dispose() {
    super.dispose();
    hideKanban();
    _rootView = null;
    isFirstInflate = true;
    print("MyNBRF: destroyed");
  }

  void showKanban() {
    if (disableAnimation) return;
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (_rootView?.visibility == Visibility.hidden) {
        print("MyNBRF: show: start, set h: ${MediaQuery.of(context).size.height}");
        _rootView?.translationY = MediaQuery.of(context).size.height.toDouble();
        _rootView?.visibility = Visibility.visible;
        // Animation logic should be implemented here
      }
    });
    print("MyNBRF: show: end");
  }

  void hideKanban() {
    if (disableAnimation) return;
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (!isHideRunning.get() && _rootView?.visibility == Visibility.visible) {
        isHideRunning.set(true);
        print("MyNBRF: hide: start, set h: ${MediaQuery.of(context).size.height}");
        // Animation logic should be implemented here
        _rootView?.visibility = Visibility.hidden;
        isHideRunning.set(false);
        print("MyNBRF: hide: set gone");
      }
    });
    print("MyNBRF: hide: end");
  }
}

// AtomicBoolean class definition should be provided for this code to work.
class AtomicBoolean {
  bool _value;
  AtomicBoolean([this._value = false]);

  bool get() => _value;

  void set(bool value) {
    _value = value;
  }
}
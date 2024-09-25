import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class MangaPagesFragmentTemplate extends StatefulWidget {
  final int inflateRes;
  final bool isLazy;
  final bool forceLoad;

  MangaPagesFragmentTemplate({
    required this.inflateRes,
    this.isLazy = true,
    this.forceLoad = false,
  });

  @override
  _MangaPagesFragmentTemplateState createState() => _MangaPagesFragmentTemplateState();
}

class _MangaPagesFragmentTemplateState extends State<MangaPagesFragmentTemplate> {
  int cardPerRow = 3;
  int cardWidth = 0;
  int cardHeight = 0;
  CardList? cardList;
  bool isEnd = false;
  int page = 0;
  bool isRefresh = false;

  String transportStringNull = "TRANSPORT_NULL";
  String transportStringError = "TRANSPORT_ERROR";

  String get netInfo {
    final ConnectivityResult connectivityResult = await (Connectivity().checkConnectivity());
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return "TRANSPORT_WIFI";
      case ConnectivityResult.mobile:
        return "TRANSPORT_CELLULAR";
      case ConnectivityResult.bluetooth:
        return "TRANSPORT_BLUETOOTH";
      case ConnectivityResult.ethernet:
        return "TRANSPORT_ETHERNET";
      case ConnectivityResult.vpn:
        return "VPN";
      default:
        return transportStringNull;
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.forceLoad && (netInfo == transportStringNull || netInfo == transportStringError)) {
      Navigator.of(context).pop();
      return;
    }
    showKanban();
    Future.delayed(Duration(milliseconds: 600), () {
      setLayouts();
    });
  }

  @override
  void dispose() {
    super.dispose();
    cardList?.exitCardList = true;
  }

  Future<void> setLayouts() async {
    final toolsBox = UITools(context);
    final widthData = toolsBox.calcWidthFromDp(8, 135);
    cardPerRow = widthData?[0] ?? 3;
    cardWidth = widthData?[2] ?? 128;
    cardHeight = (cardWidth / 0.75 + 0.5).toInt();

    setState(() {
      mysp.footerView.lht.text = "加载";
      mysp.headerView.lht.text = "刷新";
      mydll?.setPadding(0, 0, 0, navBarHeight);
    });

    debugPrint("Card per row: $cardPerRow");
    debugPrint("Card width: $cardWidth");
    initCardList(WeakReference(this));
    managePage();
    setListeners();
    hideKanban();
  }

  Future<void> managePage() async {
    addPage();
    if (widget.isLazy) {
      mysp.post(() {
        setListener(SpringView.OnFreshListener(
          onLoadmore: () {
            addPage();
          },
          onRefresh: () {
            showKanban();
            reset();
            Future.delayed(Duration(milliseconds: 600), () {
              addPage();
              hideKanban();
            });
          },
        ));
      });
    }
  }

  Future<void> addPage() async {
    // Implementation here
  }

  Future<void> onLoadFinish() async {
    setState(() {
      mypc?.visibility = View.GONE;
      mysp?.onFinishFreshAndLoad();
    });
  }

  Future<void> reset() async {
    setState(() {
      mydll.removeAllViews();
      isEnd = false;
      page = 0;
      cardList?.reset();
      mypc?.visibility = View.VISIBLE;
      mypl?.progress = 0;
    });
  }

  void initCardList(WeakReference<StatefulWidget> weakReference) {
    // Implementation here
  }

  void setListeners() {
    // Implementation here
  }

  void setProgress(int p) {
    int newP = p;
    mypl?.post(() {
      if (p == mypl?.progress) return;
      if (newP >= 100) {
        debugPrint("set 100, hide");
        setState(() {
          mypc?.visibility = View.GONE;
        });
        return;
      } else if (newP < 0) newP = 0;
      setState(() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          mypl?.setProgress(newP, true);
        } else {
          mypl?.progress = newP;
        }
        mypl?.invalidate();
        debugPrint("set ${mypl?.progress}");
      });
    });
  }

  void showKanban() {
    // Implementation here
  }

  void hideKanban() {
    // Implementation here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}


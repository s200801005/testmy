// This code is translated from Kotlin to Dart for a Flutter application.

import 'package:flutter/material.dart';
import 'package:your_package/gson.dart'; // Adjust the import as per your project structure
import 'package:your_package/pausable_downloader.dart'; // Adjust the import as per your project structure
import 'package:your_package/cm_api.dart'; // Adjust the import as per your project structure
import 'package:your_package/filter_structure.dart'; // Adjust the import as per your project structure
import 'package:your_package/theme_structure.dart'; // Adjust the import as per your project structure

class SortFragment extends StatefulWidget {
  @override
  _SortFragmentState createState() => _SortFragmentState();
}

class _SortFragmentState extends State<SortFragment> {
  int theme = -1;
  int region = -1;
  FilterStructure? filter;

  String getApiUrl() {
    return 'your_api_url_here'; // Replace with actual logic to build the API URL
  }

  @override
  void initState() {
    super.initState();
    setListeners();
  }

  void setListeners() async {
    setProgress(5);
    await PausableDownloader(getString(R.string.filterApiUrl).format(CMApi.myHostApiUrl)).run((inputStream) {
      if (ad?.exit == true) return;
      filter = Gson().fromJson(inputStream.reader(), FilterStructure);
      if (ad?.exit == true) return;
      setClasses();
    });
  }

  void setClasses() {
    setProgress(10);
    filter?.results?.top?.let((items) {
      setMenu(items, lineSortRegion, (index) {
        region = index;
      });
    });
    setProgress(15);
    filter?.results?.theme?.let((items) {
      setMenu(items, lineSortClass, (index) {
        theme = index;
      });
    });
  }

  void setMenu(List<ThemeStructure> items, View line, Function(int) setIndex) {
    if (ad?.exit == true) return;
    line.apt.text = "全部";
    line.onClick(() {
      final popupMenu = PopupMenu(
        style: R.style.Widget_MPM_Menu_Dark_CustomBackground,
        section: [
          MenuItem(
            label: "全部",
            labelColor: line.apt.currentTextColor,
            callback: () {
              setIndex(-1);
              line.apt.text = "全部";
              delayedRefresh(400);
            },
          ),
          for (var i = 0; i < items.length; i++)
            MenuItem(
              label: items[i].name,
              labelColor: line.apt.currentTextColor,
              callback: () {
                line.apt.text = items[i].name;
                setIndex(i);
                delayedRefresh(400);
              },
            ),
        ],
      );
      context?.let((c) {
        popupMenu.show(c, line);
      });
    });
  }

  void setProgress(int progress) {
    // Implement your progress setting logic
  }

  // Other methods and properties...
}
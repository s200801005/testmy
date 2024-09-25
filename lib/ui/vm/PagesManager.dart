// Translated from Kotlin to Dart
// Framework: Flutter

import 'package:flutter/material.dart';
import 'package:your_package_name/reader.dart'; // Update with the actual package name
import 'package:your_package_name/r.dart'; // Update with the actual resource management

class PagesManager {
  final WeakReference<ViewMangaActivity> weakReference;

  PagesManager(this.weakReference);

  ViewMangaActivity? get view => weakReference.get();
  bool isEndLeft = false;
  bool isEndRight = false;

  bool get canGoPrevious => (view?.pageNum ?? 0) > 1;
  bool get canGoNext => (view?.pageNum ?? 0) < (view?.realCount ?? 0);

  void toPreviousPage() {
    toPage(view?.r2l == true);
  }

  void toNextPage() {
    toPage(view?.r2l != true);
  }

  void toPage(bool goNext) {
    final currentView = view;
    if (currentView != null) {
      if (currentView.clicked == 1) {
        currentView.hideDrawer();
        return;
      }
      if (goNext ? canGoNext : canGoPrevious) {
        if (goNext) {
          currentView.scrollForward();
          isEndRight = false;
        } else {
          currentView.scrollBack();
          isEndLeft = false;
        }
        return;
      }
      final int chapterPosition = currentView.position + (goNext ? 1 : -1);
      if (currentView.urlArray.isEmpty) return;

      if (chapterPosition < 0 || chapterPosition >= currentView.urlArray.length) {
        ScaffoldMessenger.of(currentView.context).showSnackBar(
          SnackBar(content: Text(R.string.end_of_chapter)),
        );
        return;
      }

      if (goNext ? isEndRight : isEndLeft) {
        currentView.tt.canDo = false;
        currentView.comicName?.let((comicName) {
          Reader.startToViewManga(comicName, chapterPosition, currentView.urlArray, currentView.uuidArray, goNext);
        });
        currentView.finish();
        return;
      }

      final hint = goNext 
          ? R.string.press_again_to_load_next_chapter 
          : R.string.press_again_to_load_previous_chapter;

      ScaffoldMessenger.of(currentView.context).showSnackBar(
        SnackBar(content: Text(hint)),
      );

      if (goNext) {
        isEndRight = true;
      } else {
        isEndLeft = true;
      }
    }
  }

  void toggleDrawer() {
    final currentView = view;
    currentView?.apply(() {
      switch (clicked) {
        case 0:
          showDrawer();
          break;
        case 1:
          hideDrawer();
          break;
      }
    });
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../../json/Chapter2Return.dart';
import '../../views/ScaleImageView.dart';

class VMHandler {
  final String chapterUrl;
  final List<String> weeks;
  Chapter2Return? manga;
  final WeakReference<ViewMangaActivity> wv;
  final Dialog dl;
  var hasDrawerShown = false;
  var delta = -1.0;
  var remainingImageCount = 0;

  VMHandler(ViewMangaActivity activity, this.chapterUrl, this.weeks)
      : wv = WeakReference(activity),
        dl = Dialog(
          child: Container(),
        );

  String get week {
    final cal = DateTime.now();
    final w = cal.weekday;
    if (w > 7 || w <= 0) return "";
    return weeks[w - 1];
  }

  void handleMessage(Message msg) {
    switch (msg.what) {
      case HIDE_INFO_CARD:
        if (hasDrawerShown) {
          hideInfCard();
          hasDrawerShown = false;
        }
        break;
      case SHOW_INFO_CARD:
        if (!hasDrawerShown) {
          showInfCard();
          hasDrawerShown = true;
        }
        break;
      case TRIGGER_INFO_CARD:
        hasDrawerShown = hasDrawerShown ? hideInfCard() : showInfCard();
        break;
      case CLEAR_IMG_ON:
        (msg.obj as ScaleImageView).post(() {
          (msg.obj as ScaleImageView).visibility = View.GONE;
        });
        break;
      case PREPARE_LAST_PAGE:
        wv.get()?.prepareLastPage(msg.arg1, msg.arg2);
        break;
      case DIALOG_SHOW:
        dl.show();
        break;
      case LOAD_ITEM_SCROLL_MODE:
        loadScrollMode(msg.arg1, msg.obj as Runnable?);
        break;
      case LOAD_SCROLL_MODE:
        loadScrollMode();
        break;
      case LOAD_ITEM_IMAGES_INTO_LINE:
        wv.get()?.lifecycleScope?.launch(() {
          loadImagesIntoLine(msg.arg1, msg.obj as Runnable?);
        });
        break;
      case LOAD_IMAGES_INTO_LINE:
        wv.get()?.lifecycleScope?.launch(() {
          loadImagesIntoLine();
        });
        break;
      case RESTORE_PAGE_NUMBER:
        sendEmptyMessage(DIALOG_HIDE);
        wv.get()?.apply(() {
          lifecycleScope.launch(() {
            restorePN();
          });
        });
        break;
      case LOAD_PAGE_FROM_ITEM:
        final verticalMaxCount = wv.get()?.verticalLoadMaxCount ?? 20;
        final item = ((wv.get()?.pn ?? 1) - 1) ~/ verticalMaxCount * verticalMaxCount;
        loadScrollMode(item);
        debugPrint("Load page from $item");
        break;
      case DIALOG_HIDE:
        dl.hide();
        break;
      case HIDE_INFO_CARD_FULL:
        if (hasDrawerShown) {
          hideInfCardFull();
          hasDrawerShown = false;
        }
        break;
      case SHOW_INFO_CARD_FULL:
        if (!hasDrawerShown) {
          showInfCardFull();
          hasDrawerShown = true;
        }
        break;
      case TRIGGER_INFO_CARD_FULL:
        hasDrawerShown = hasDrawerShown ? hideInfCardFull() : showInfCardFull();
        break;
      case INIT_IMAGE_COUNT:
        remainingImageCount = msg.arg1;
        debugPrint("init remainingImageCount = $remainingImageCount");
        break;
      case DECREASE_IMAGE_COUNT_AND_RESTORE_PAGE_NUMBER_AT_ZERO:
        if (--remainingImageCount == 0) {
          debugPrint("last load page, restore pn...");
          sendEmptyMessageDelayed(RESTORE_PAGE_NUMBER, 233);
        }
        debugPrint("remainingImageCount = $remainingImageCount");
        break;
      case DO_LAMBDA:
        (msg.obj as Runnable?)?.run();
        break;
      case SET_NET_INFO:
        wv.get()?.idtime?.text = DateFormat("HH:mm").format(DateTime.now()) + week + wv.get()?.toolsBox?.netInfo;
        break;
      case SET_DL_TEXT:
        dl.tunz.text = msg.obj as String;
        break;
    }
  }

  Chapter2Return? getGsonItem() => manga;

  bool setGsonItem(dynamic gsonObj) {
    final m = gsonObj as Chapter2Return;
    if (m.results.chapter.words.length != m.results.chapter.contents.length) {
      return false;
    }
    if (m.results.chapter.words.length != m.results.chapter.size) {
      m.results.chapter.size = m.results.chapter.words.length;
    }
    manga = m;
    return true;
  }

  Future<void> onError() async {
    if (exit) return;
    await runBlocking(() {
      wv.get()?.toolsBox?.toastError(R.string.download_chapter_info_failed);
    });
  }

  Future<void> doWhenFinishDownload() async {
    if (exit) return;
    prepareManga();
  }

  Future<bool> loadFromFile(File file) async {
    fakeLoad();
    try {
      final jsonFile = File('${file.parent.path}/${basenameWithoutExtension(file.path)}.json');
      if (jsonFile.existsSync()) {
        manga = Chapter2Return.fromJson(jsonDecode(jsonFile.readAsStringSync()));
        prepareManga();
      } else {
        manga = Chapter2Return();
        manga?.results = Chapter2Return.Results();
        manga?.results.comic = ComicStructure();
        manga?.results.comic.name = file.parent.parent.path.split(Platform.pathSeparator).last;
        manga?.results.chapter = ChapterWithContent();
        manga?.results.chapter.name = basenameWithoutExtension(file.path);
        wv.get()?.apply(() {
          manga?.results.chapter.uuid = uuidArray[position];
          countZipEntries((c) {
            manga?.results.chapter.size = c;
            prepareManga();
          });
        });
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      wv.get()?.toolsBox?.toastError(R.string.load_local_chapter_info_failed);
      return false;
    }
  }

  void fakeLoad() {
    if (MainActivity.member?.hasLogin == true) {
      Thread(() {
        runBlocking(() {
          PausableDownloader(chapterUrl, () {}).run();
        });
      }).start();
    }
  }

  Future<void> prepareManga() async {
    await runBlocking(() {
      wv.get()?.apply(() {
        if (comicName == null) {
          comicName = manga?.results?.comic?.name;
        }
        count = manga?.results?.chapter?.size ?? 0;
        initManga();
        vprog?.visibility = View.GONE;
      });
    });
  }

  Future<void> loadImagesIntoLine([int item = 0, Runnable? doAfter]) async {
    final maxCount = wv.get()?.verticalLoadMaxCount ?? 20;
    debugPrint("Fun: loadImagesIntoLine($item, $maxCount)");
    final count = wv.get()?.realCount;
    if (count != null && count > 0) {
      final notFull = item + maxCount > count;
      final loadCount = (notFull ? count - item : maxCount) - 1;
      obtainMessage(INIT_IMAGE_COUNT, loadCount + 1, 0).sendToTarget();
      debugPrint("count: $count, loadCount: $loadCount, notFull: $notFull");
      if (loadCount >= 0) {
        await runBlocking(() async {
          for (var i = 0; i <= loadCount; i++) {
            wv.get()?.apply(() {
              final p = item + i;
              scrollPositions[i] = p;
              launch(() {
                loadImgOn(scrollImages[i], scrollButtons[i], p, false);
              });
            });
          }
        });
        if (notFull) obtainMessage(PREPARE_LAST_PAGE, loadCount + 1, maxCount).sendToTarget();
        obtainMessage(DO_LAMBDA, Runnable(() {
          doAfter?.run();
          wv.get()?.apply(() {
            lifecycleScope.launch(() {
              updateSeekBar(0);
            });
          });
        })).sendToTarget();
      }
    }
  }

  void loadScrollMode() {
    sendEmptyMessage(DIALOG_SHOW);
    sendEmptyMessage(LOAD_IMAGES_INTO_LINE);
  }

  void loadScrollMode(int item, [Runnable? doAfter]) {
    sendEmptyMessage(DIALOG_SHOW);
    debugPrint("loadImgsIntoLine($item)");
    obtainMessage(LOAD_ITEM_IMAGES_INTO_LINE, item, 0, doAfter).sendToTarget();
  }

  void showInfCard() {
    debugPrint("Read info drawer delta: $delta");
    ObjectAnimator.ofFloat(drawer?.idc, "alpha", 0.3, 0.8).setDuration(233).start();
    ObjectAnimator.ofFloat(drawer, "translationY", delta, 0.0).setDuration(233).start();
  }

  void showInfCardFull() {
    debugPrint("Read info drawer delta: $delta");
    ObjectAnimator.ofFloat(drawer?.idc, "alpha", 0.0, 0.8).setDuration(233).start();
    ObjectAnimator.ofFloat(drawer, "translationY", delta, 0.0).setDuration(233).start();
  }

  void hideInfCard() {
    ObjectAnimator.ofFloat(drawer?.idc, "alpha", 0.8, 0.3).setDuration(233).start();
    ObjectAnimator.ofFloat(drawer, "translationY", 0.0, delta).setDuration(233).start();
  }

  void hideInfCardFull() {
    ObjectAnimator.ofFloat(drawer?.idc, "alpha", 0.8, 0.0).setDuration(233).start();
    ObjectAnimator.ofFloat(drawer, "translationY", 0.0, delta).setDuration(233).start();
  }

  static const int HIDE_INFO_CARD = 1;
  static const int SHOW_INFO_CARD = 2;
  static const int TRIGGER_INFO_CARD = 3;
  static const int CLEAR_IMG_ON = 5;
  static const int PREPARE_LAST_PAGE = 6;
  static const int DIALOG_SHOW = 7;
  static const int LOAD_ITEM_SCROLL_MODE = 9;
  static const int LOAD_SCROLL_MODE = 10;
  static const int LOAD_ITEM_IMAGES_INTO_LINE = 11;
  static const int LOAD_IMAGES_INTO_LINE = 12;
  static const int RESTORE_PAGE_NUMBER = 13;
  static const int LOAD_PAGE_FROM_ITEM = 14;
  static const int DIALOG_HIDE = 15;
  static const int HIDE_INFO_CARD_FULL = 16;
  static const int SHOW_INFO_CARD_FULL = 17;
  static const int TRIGGER_INFO_CARD_FULL = 18;
  static const int INIT_IMAGE_COUNT = 19;
  static const int DECREASE_IMAGE_COUNT_AND_RESTORE_PAGE_NUMBER_AT_ZERO = 20;
  static const int DO_LAMBDA = 21;
  static const int SET_NET_INFO = 22;
  static const int SET_DL_TEXT = 23;
}


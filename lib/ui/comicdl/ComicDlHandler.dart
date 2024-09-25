import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

import '../../json/ChapterStructure.dart';
import '../../json/VolumeStructure.dart';
import '../../manga/MangaDlTools.dart';
import '../../manga/Reader.dart';
import '../../tools/api/CMApi.dart';
import '../../views/ChapterToggleButton.dart';
import '../vm/ViewMangaActivity.dart';

class ComicDlHandler {
  final BuildContext context;
  final List<VolumeStructure> vols;
  final String comicName;
  final List<String>? groupNames;
  bool isOld = false;
  bool complete = false;
  bool haveSElectAll = false;
  int checkedChapter = 0;
  int dldChapter = 0;
  List<ChapterToggleButton> tbtnlist = [];
  int tbtncnt = 0;
  bool isNewTitle = false;
  final MangaDlTools mangaDlTools = MangaDlTools();
  bool multiSelect = false;
  List<bool?> finishMap = [];
  bool downloading = false;
  List<String> urlArray = [];
  List<String> uuidArray = [];
  int maxBatch = 16;

  ComicDlHandler(this.context, this.vols, this.comicName, this.groupNames) {
    SharedPreferences.getInstance().then((prefs) {
      maxBatch = prefs.getInt('settings_cat_md_sb_max_batch') ?? 16;
    });
  }

  ComicDlHandler.old(this.context, this.comicName, this.vols, this.groupNames) {
    isOld = true;
  }

  Future<void> handleMessage(int msg) async {
    switch (msg) {
      case 0:
      // Hide dialog
        break;
      case 4:
        await _toggleSelectAll();
        break;
      case 6:
        _updateProgressBar();
        break;
      case 7:
        await _deleteChapters(msg.obj as File, msg.arg1);
        break;
      case 9:
        _setCardBackgroundColor(Colors.green);
        break;
      case 13:
        if (complete) _showMultiSelectInfo();
        break;
    }
  }

  Future<void> startLoad() async {
    await _setComponents();
    if (isOld) {
      await _analyzeOldStructure();
    } else {
      urlArray = [];
      Reader.fileArray = [];
      uuidArray = [];
      for (var vol in vols) {
        var caption = groupNames?[vols.indexOf(vol)] ?? vol.results.list[0].group_path_word;
        await _addCaption(caption, () async {
          await _addButtons(vol.results.list, caption);
        });
      }
      complete = true;
    }
    _hideKanban();
  }

  Future<void> _addDiv() async {
    context.findRenderObject()?.addView(
      context.inflate(R.layout.div_h, context, false),
      ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.WRAP_CONTENT,
      ),
    );
  }

  Future<void> _addCaption(String title, Function body) async {
    var tc = context.inflate(R.layout.line_caption, context, false);
    tc.tcptn.text = title;
    context.findRenderObject()?.addView(
      tc,
      ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.WRAP_CONTENT,
      ),
    );
    await _addDiv();
    isNewTitle = true;
    await body();
  }

  Future<void> _deleteChapter(File f, ChapterToggleButton v) async {
    await f.delete();
    v.setBackgroundResource(R.drawable.toggle_button);
    v.isChecked = false;
  }

  Future<void> _deleteChapters(File zipf, int index) async {
    if (multiSelect) {
      for (var i in tbtnlist) {
        if (i.isChecked) {
          var f = CMApi.getZipFile(await getExternalFilesDir(), comicName, i.caption ?? "null", i.chapterName);
          if (await f.exists()) {
            await _deleteChapter(f, i);
            checkedChapter--;
          }
        }
      }
      multiSelect = false;
      handleMessage(6);
    } else {
      await _deleteChapter(zipf, tbtnlist[index]);
    }
  }

  bool _isChapterExists(String chapter, String caption) {
    return File('${await getExternalFilesDir()}/$comicName/$caption/$chapter.zip').existsSync();
  }

  void _updateProgressBar() {
    context.findRenderObject()?.tdwn?.text = '$dldChapter/$checkedChapter';
    _setProgress2(dldChapter * 100 ~/ (checkedChapter > 0 ? checkedChapter : 1), 233);
  }

  void _setProgress2(int end, int duration) {
    AnimationController(
      vsync: context,
      duration: Duration(milliseconds: duration),
    ).animateTo(end);
  }

  Future<void> _setComponents() async {
    var widthData = await _calcWidthFromDpRoot(8, 64);
    btnNumPerRow = widthData[0];
    btnw = widthData[1];
    var dl = Dialog(context: context);
    dl.content = R.layout.dialog_unzipping;
    context.findRenderObject()?.dlsdwn?.viewTreeObserver?.addOnGlobalLayoutListener(() {
      cdwnWidth = context.findRenderObject()?.dlsdwn.width ?? 0;
      context.findRenderObject()?.dlsdwn.viewTreeObserver.removeOnGlobalLayoutListener(this);
    });
    context.findRenderObject()?.dllazys?.onScrollListener = _OnScrollListener();
    context.findRenderObject()?.cdwn?.onClickListener = () {
      if (context.findRenderObject()?.dlsdwn.translationX != 0) {
        _showDlCard();
      } else if (checkedChapter == 0) {
        _hideDlCard();
      } else {
        context.findRenderObject()?.pdwn.progress = 0;
        if (downloading || checkedChapter == 0) {
          mangaDlTools.wait = !mangaDlTools.wait;
        } else {
          downloading = true;
          handleMessage(9);
          finishMap = List.filled(tbtnlist.length, null);
          _downloadChapterPages();
        }
      }
    };
    context.findRenderObject()?.cdwn?.onLongClickListener = () {
      handleMessage(4);
      return true;
    };
    mangaDlTools.onDownloadedListener = _OnDownloadedListener();
  }

  void _showMultiSelectInfo() {
    if (multiSelect) {
      _buildInfo("退出多选模式？", "退出后只能对单个漫画进行长按删除", "确定", null, "取消", () {
        multiSelect = false;
      });
      return;
    }
    _buildInfo("进���多选模式？", "之后可以对已下载漫画进行批量删除/重新下载", "确定", null, "取消", () {
      multiSelect = true;
    });
  }

  Future<void> _downloadChapterPages() async {
    var totalInDownload = AtomicInteger(0);
    for (var i in tbtnlist) {
      if (i.isChecked) {
        i.isEnabled = false;
        if (i.url != null) {
          while (totalInDownload.get() >= maxBatch) {
            await Future.delayed(Duration(seconds: 1));
          }
          totalInDownload.incrementAndGet();
          await _downloadChapterInVol(i.url!, i.chapterName, i.caption ?? "null", i.index);
          totalInDownload.decrementAndGet();
        }
      }
    }
  }

  Future<void> _onZipDownloadFinish(int index) async {
    if (index >= 0 && index < tbtnlist.length) {
      tbtnlist[index].setBackgroundResource(R.drawable.rndbg_checked);
      tbtnlist[index].isChecked = false;
      tbtnlist[index].isEnabled = true;
      finishMap[index] = true;
      _updateProgressBar();
      context.apply(() {
        cdwn.postDelayed(() {
          if (mangaDlTools.exit) return;
          if (dldChapter == checkedChapter) {
            checkedChapter = 0;
            _setProgress2(0, 233);
            tdwn.text = "0/0";
            cdwn.setCardBackgroundColor(Colors.blue);
            finishMap = [];
            downloading = false;
          }
        }, 400);
      });
    }
  }

  Future<void> _onZipDownloadFailure(int index, String message) async {
    if (exit) return;
    tbtnlist[index].setBackgroundResource(R.drawable.rndbg_error);
    tbtnlist[index].isEnabled = true;
    Fluttertoast.showToast(msg: "下载${tbtnlist[index].chapterName}失败: $message");
    _updateProgressBar();
  }

  void _showDlCard() {
    AnimationController(
      vsync: context,
      duration: Duration(milliseconds: 233),
    ).animateTo(cdwnWidth.toDouble() * 0.9, 0);
  }

  void _hideDlCard() {
    AnimationController(
      vsync: context,
      duration: Duration(milliseconds: 233),
    ).animateTo(0, cdwnWidth.toDouble() * 0.9);
  }

  Future<void> _addButtons(List<ChapterStructure> chapters, String caption) async {
    for (var chapter in chapters) {
      var u = CMApi.getChapterInfoApiUrl(chapter.comic_path_word, chapter.uuid) ?? "";
      await _addButton(chapter.name, chapter.uuid, caption, u);
      urlArray.add(u);
    }
    await _addDiv();
  }

  Future<void> _addButton(String title, String uuid, String caption, String url) async {
    if ((tbtncnt % btnNumPerRow == 0) || isNewTitle) {
      context.findRenderObject()?.ltbtn = context.inflate(R.layout.line_horizonal_empty, context, false);
      context.findRenderObject()?.ldwn?.addView(context.findRenderObject()?.ltbtn);
      tbtncnt = 0;
      isNewTitle = false;
    }
    var tbv = context.inflate(R.layout.button_tbutton, context.findRenderObject()?.ltbtn?.ltbtn, false);
    tbv.tbtn.index = tbtnlist.length;
    tbtnlist.add(tbv.tbtn);
    tbtncnt++;

    tbv.tbtn.uuid = uuid;
    uuidArray.add(uuid);
    tbv.tbtn.chapterName = title;
    tbv.tbtn.url = url;
    tbv.tbtn.caption = caption;
    tbv.tbtn.layoutParams.width = btnw;

    context.findRenderObject()?.ltbtn?.ltbtn?.addView(tbv);
    context.findRenderObject()?.ltbtn?.invalidate();

    var zipf = CMApi.getZipFile(await getExternalFilesDir(), comicName, caption, title);
    Reader.fileArray.add(zipf);
    if (await zipf.exists()) {
      tbv.tbtn.setBackgroundResource(R.drawable.rndbg_checked);
      tbv.tbtn.isChecked = false;
    }
    tbv.tbtn.onClickListener = () {
      if (await zipf.exists() && !multiSelect) {
      tbv.tbtn.setBackgroundResource(R.drawable.rndbg_checked);
      tbv.tbtn.isChecked = false;
      ViewMangaActivity.dlHandler = this;
      dl?.show();
      Reader.viewMangaZipFile(tbv.tbtn.index, urlArray, uuidArray, zipf);
      } else {
      tbv.tbtn.setBackgroundResource(R.drawable.toggle_button);
      if (tbv.tbtn.isChecked) {
      context.findRenderObject()?.tdwn?.text = "$dldChapter/${++checkedChapter}";
      } else {
      context.findRenderObject()?.tdwn?.text = "$dldChapter/${--checkedChapter}";
      }
      }
    };
    tbv.tbtn.onLongClickListener = () {
      if (await zipf.exists()) {
      _buildInfo("确认删除${multiSelect ? "这些" : "本"}章节?", "该操作将不可撤销", "确定", null, "取消", () {
      handleMessage(7, tbv.tbtn.index, 0, zipf);
      });
      } else {
      _buildInfo("直接观看", "不下载而进行���看", "确定", null, "取消", () {
      ViewMangaActivity.dlHandler = this;
      dl?.show();
      Reader.start2viewManga(null, tbv.tbtn.index, urlArray, uuidArray);
      }, null, null);
      }
      return true;
    };
  }

  Future<void> _analyzeOldStructure() async {
    var jsonData = jsonDecode(json);
    for (var group in jsonData) {
      var tc = context.inflate(R.layout.line_caption, context, false);
      tc.tcptn.text = group['name'];
      context.findRenderObject()?.ldwn?.addView(
        tc,
        ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT,
          ViewGroup.LayoutParams.WRAP_CONTENT,
        ),
      );
      context.findRenderObject()?.ldwn?.addView(
        context.inflate(R.layout.div_h, context, false),
        ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT,
          ViewGroup.LayoutParams.WRAP_CONTENT,
        ),
      );
      isNewTitle = true;
      for (var chapter in group['chapters']) {
        var newUrl = CMApi.getChapterInfoApiUrl(
          chapter['url'].substringAfter("/comic/").substringBefore('/'),
          chapter['url'].substringAfterLast('/'),
        ) ?? "";
        await _addButton(chapter['name'], "", group['name'], newUrl);
        urlArray.add(newUrl);
      }
    }
  }

  Future<List<int>> _calcWidthFromDpRoot(int min, int max) async {
    // Implementation of _calcWidthFromDpRoot
    return [min, max];
  }

  void _hideKanban() {
    // Implementation of _hideKanban
  }

  void _buildInfo(String title, String message, String confirmText, String? neutralText, String cancelText, Function onConfirm) {
    // Implementation of _buildInfo
  }

  Future<Directory> getExternalFilesDir() async {
    return (await getExternalStorageDirectory())!;
  }

  Future<void> _toggleSelectAll() async {
    if (haveSElectAll) {
      for (var i in tbtnlist) {
        if (!_isChapterExists(i.chapterName, i.caption ?? "null")) {
          i.setBackgroundResource(R.drawable.toggle_button);
          i.isChecked = false;
        } else if (multiSelect) {
          i.setBackgroundResource(R.drawable.rndbg_checked);
          i.isChecked = false;
        }
      }
      haveSElectAll = false;
      checkedChapter = 0;
    } else {
      for (var i in tbtnlist) {
        if (multiSelect || !i.isChecked && !_isChapterExists(i.chapterName, i.caption ?? "null")) {
          i.setBackgroundResource(R.drawable.toggle_button);
          i.isChecked = true;
          checkedChapter++;
        }
      }
      haveSElectAll = true;
    }
    context.findRenderObject()?.tdwn?.text = "$dldChapter/$checkedChapter";
  }

  class _OnScrollListener implements LazyScrollView.OnScrollListener {
  @override
  void onBottom() {
  // Implementation of onBottom
  }

  @override
  void onScroll() {
  if (context.findRenderObject()?.dlsdwn?.translationX == 0) {
  _hideDlCard();
  }
  }

  @override
  void onTop() {
  // Implementation of onTop
  }
  }

  class _OnDownloadedListener implements MangaDlTools.OnDownloadedListener {
  @override
  void handleMessage(int index, bool isSuccess, String message) {
  if (isSuccess) {
  _onZipDownloadFinish(index);
  } else {
  _onZipDownloadFailure(index, message);
  }
  }

  @override
  void handleMessage(int index, int downloaded, int total, bool isSuccess, String message) {
  if (isSuccess) {
  tbtnlist[index].text = downloaded == 0 && total == 0 ? tbtnlist[index].chapterName : "$downloaded/$total";
  } else {
  tbtnlist[index].text = "$downloaded/$total";
  FlutterToast.showToast(msg: "下载${tbtnlist[index].chapterName}的第${downloaded}页失败: $message");
  }
  }
  }
}

class _setCardBackgroundColor {
}


// This code sample is a translation from Kotlin to Dart for an Android application.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:archive/archive.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:your_package/your_tools.dart'; // Adjust import according to your tools
import 'package:your_package_name/your_image_loader.dart'; // Replace with actual image loading package
import 'package:dio/dio.dart'; // Assuming Dio is used for HTTP requests
import 'package:flutter/widgets.dart';
import 'package:your_package_name/your_other_dependencies.dart'; // Replace with actual dependencies

// This code is translated from Kotlin to Dart
class ViewMangaActivity extends TitleActivityTemplate {
  int itemCount = 0;
  late VMHandler handler;
  late TimeThread timeThread;
  int clickCount = 0;
  bool isSeeking = false;
  bool isScrolling = true;
  // PropertiesTools? progressLog; // Commented out for now
  List<ScaleImageView> scaleImageViews = [];
  List<Button> buttons = [];
  List<int> scrollPositions = [];
  // bool isZipFirst = false; // Commented out for now
  // bool isFullScreen = false; // Commented out for now
  bool isRightToLeft = true;
  int currentItemIndex = 0;
  int verticalLoadMaxCount = 20;
  bool isNotUsingViewPager = true;
  bool isVerticalOrientation = false;
  int quality = 100;
  bool tryWebpFirst = true;

  int get size => (realCount ~/ verticalLoadMaxCount > currentItemIndex ~/ verticalLoadMaxCount) 
      ? verticalLoadMaxCount 
      : realCount % verticalLoadMaxCount;

  double infoDrawerDelta = 0.0;

  int get pageNum => getPageNumber();
  set pageNum(int value) => setPageNumber(value);

  bool get isPageNumberValid {
    bool isValid = forceLetPageNumberValid || (pageNumber == -2) 
        ? (pageNumber = 0) == 0 
        : (intent.getStringExtra("function") == "log" && pageNumber > 0);
    print("MyVM: isPageNumberValid: $isValid");
    return isValid && pageNumber <= realCount;
  }

  bool get forceLetPageNumberValid {
    if (!field) return false;
    field = false;
    return true;
  }
}

class MyClass {
  List<Future<Task>?>? tasks;
  List<bool>? tasksRunStatus;
  bool isDestroyed = false;
  bool isCut = false;
  List<bool> isCutArray = [];
  List<int> indexMap = [];
  bool isVolumeTurnPage = false;
  AudioManager? audioManager;
  PagesManager? pagesManager;
  bool isFullyHideInfo = false;
  
  int get realCount => isCut ? indexMap.length : count;

  List<String> urlArray = [];
  List<String> uuidArray = [];
  int currentPosition = 0;
  String? comicName;
  File? zipFile;
  int pageNumber = 0;

  final AtomicInteger loadImgOnWait = AtomicInteger();

  int _colorOnSurface = 0;

  int get colorOnSurface {
    if (_colorOnSurface != 0) return _colorOnSurface;
    final TypedValue tv = TypedValue();
    _colorOnSurface = theme.resolveAttribute(R.attr.colorOnSurface, tv, true)
        ? tv.data
        : ContextCompat.getColor(applicationContext, R.color.material_on_surface_stroke);
    return _colorOnSurface;
  }
}

class ViewMangaActivity extends StatefulWidget {
  @override
  _ViewMangaActivityState createState() => _ViewMangaActivityState();
}

class _ViewMangaActivityState extends State<ViewMangaActivity> {
  // Assume other variables are declared here
  late List<String> urlArray;
  late List<String> uuidArray;
  late int position;
  late String? comicName;
  late File? zipFile;
  late int pn;
  late bool cut;
  late bool r2l;
  late int verticalLoadMaxCount;
  late bool isVertical;
  late bool notUseVP;
  late bool noCellarAlert;
  late bool fullyHideInfo;
  
  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }
  
  void _initializeSettings() async {
    final settingsPref = await getDefaultSharedPreferences();

    if (settingsPref?.getBoolean("settings_cat_vm_sw_always_dark_bg", false) ?? false) {
      print("force dark");
      // Set the app's theme to dark
      // Note: Flutter handles themes differently than Android
    } else {
      // Set the app's theme to follow system settings
    }

    // Assume other initializations based on intent data
    urlArray = []; // Initialize with actual data
    uuidArray = []; // Initialize with actual data
    position = 0; // Initialize with actual data
    comicName = ""; // Initialize with actual data
    zipFile = null; // Initialize with actual data
    pn = 0; // Initialize with actual data
    cut = false; // Initialize with actual data
    r2l = false; // Initialize with actual data
    verticalLoadMaxCount = (settingsPref?.getInt("settings_cat_vm_sb_vertical_max", 20) ?? 20).clamp(20, double.infinity).toInt();
    isVertical = false; // Initialize with actual data
    notUseVP = false; // Initialize with actual data

    // Assume the handler initialization is done here
    final mHandler = VMHandler(this, urlArray.isNotEmpty ? urlArray[position] : "", []);
    
    // Simulating asynchronous behavior
    await Future.delayed(Duration.zero, () async {
      final quality = (settingsPref?.getInt("settings_cat_vm_sb_quality", 100) ?? 100).clamp(100, double.infinity);
      // Assume TimeThread starts here
      final timeThread = TimeThread(mHandler, VMHandler.SET_NET_INFO, 10000);
      timeThread.canDo = true;
      timeThread.start();
      
      final volTurnPage = settingsPref?.getBoolean("settings_cat_vm_sw_vol_turn", false) ?? false;
      // Assume audio manager initialization is done here

      if (!noCellarAlert) {
        noCellarAlert = settingsPref?.getBoolean("settings_cat_net_sw_use_cellar", false) ?? false;
      }
      fullyHideInfo = settingsPref?.getBoolean("settings_cat_vm_sw_hide_info", false) ?? false;

      print("Now ZipFile is $zipFile");
      try {
        if (zipFile != null && await zipFile!.exists()) {
          if (!mHandler.loadFromFile(zipFile!)) prepareImgFromWeb();
        } else {
          prepareImgFromWeb();
        }
      } catch (e) {
        print(e);
        // Show error message
      }

      // Animation logic can be added here
    });

    // System bar settings can be set here
  }

  Future<Map<String, dynamic>?> getDefaultSharedPreferences() async {
    // This function should return the shared preferences
    return {};
  }

  void prepareImgFromWeb() {
    // Your logic to prepare images from the web
  }
}

class VMHandler {
  VMHandler(ViewMangaActivity activity, String url, List<String> weeks);
  bool loadFromFile(File file) {
    // Load file logic
    return false;
  }

  static const int SET_NET_INFO = 1;
}

class TimeThread {
  TimeThread(VMHandler handler, int setNetInfo, int duration);
  bool canDo = false;
  void start() {
    // Start thread logic
  }
}

class YourClassName extends StatefulWidget {
  @override
  _YourClassNameState createState() => _YourClassNameState();
}

class _YourClassNameState extends State<YourClassName> {
  bool volTurnPage = false;
  PageManager? pm;
  bool noCellarAlert = false;
  final mHandler = Handler();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Additional setup if needed
  }

  @override
  void onWindowFocusChanged(bool hasFocus) {
    super.onWindowFocusChanged(hasFocus);
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Set system UI visibility based on Android version
      if (Theme.of(context).platform == TargetPlatform.android) {
        // Use appropriate flags for system UI visibility
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        // Handle newer Android versions
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      }
    }
  }

  @override
  bool onKeyDown(int keyCode, RawKeyEvent event) {
    bool flag = false;
    if (volTurnPage) {
      switch (keyCode) {
        case KeyEvent.KEYCODE_VOLUME_UP:
          pm?.toPage(false);
          flag = true;
          break;
        case KeyEvent.KEYCODE_VOLUME_DOWN:
          pm?.toPage(true);
          flag = true;
          break;
      }
    }
    return flag ? true : super.onKeyDown(keyCode, event);
  }

  Future<void> alertCellar() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("注意"),
          content: Text("要使用使用流量观看吗？"),
          actions: [
            TextButton(
              onPressed: () {
                mHandler.startLoad();
                Navigator.of(context).pop();
              },
              child: Text("确定"),
            ),
            TextButton(
              onPressed: () {
                noCellarAlert = true;
                mHandler.startLoad();
                Navigator.of(context).pop();
              },
              child: Text("本次阅读不再提醒"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                finish();
              },
              child: Text("取消"),
            ),
          ],
        );
      },
    );
  }
}

class PageManager {
  void toPage(bool nextPage) {
    // Implementation of page navigation
  }
}

class Handler {
  void startLoad() {
    // Implementation of loading mechanism
  }
}

Future<void> restorePageNumber() async {
  if (isPageNumberValid) {
    isInScroll = false;
    pageNumber = pageNumberValue;
    debugPrint("MyVM: restore pageNumber to $pageNumberValue");
    pageNumberValue = -1;
  }
  setProgress();
}

void prepareDownloadTasks() {
  final imageUrlArray = getImageUrlArray();
  if (imageUrlArray != null) {
    tasks = List.generate(imageUrlArray.length, (index) {
      final url = imageUrlArray[index];
      if (url == null) return null;
      return DownloadTools.prepare(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(url) ?? url));
    });
    tasksRunStatus = List.generate(imageUrlArray.length, (index) => false);
  }
}

@experimental
Future<void> doPrepareWebImage() async {
  final imageUrlArray = getImageUrlArray();
  if (imageUrlArray != null) {
    if (isCutEnabled) {
      debugPrint("MyVM: is cut, load all pages...");
      mHandler.sendEmptyMessage(VMHandler.DIALOG_SHOW); // showDl
      isCut = List.filled(imageUrlArray.length, false);
      for (var index = 0; index < imageUrlArray.length; index++) {
        mHandler.obtainMessage(VMHandler.SET_DL_TEXT, "${index + 1}/${imageUrlArray.length}").sendToTarget();
        final url = imageUrlArray[index];
        if (url != null) {
          try {
            final inputStream = await DownloadTools.getHttpContent(CMApi.resolution.wrap(CMApi.imageProxy?.wrap(url) ?? url), 1024);
            if (inputStream != null) {
              isCut[index] = canCut(inputStream);
            } else {
              await Future.delayed(Duration.zero); // to switch context
              showToast(context, R.string.touch_img_error);
              finishActivity();
              return;
            }
          } catch (e) {
            debugPrintStack();
            await Future.delayed(Duration.zero); // to switch context
            showToast(context, R.string.analyze_img_size_error);
            finishActivity();
            return;
          }
        }
      }
      for (var i = 0; i < isCut.length; i++) {
        debugPrint("MyVM: [${i}] cut: ${isCut[i]}");
        indexMap.add(i + 1);
        if (isCut[i]) indexMap.add(-(i + 1));
      }
      mHandler.sendEmptyMessage(15); // hideDl
      debugPrint("MyVM: load all pages finished");
    }
    itemCount = imageUrlArray.length;
    prepareItems();
    if (!isViewPagerUsed) {
      prepareDownloadTasks();
    }
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void finishActivity() {
  // Implement activity finish logic here
}

class MyViewModel {
  int pn = -4;
  File? zipFile;
  bool isVertical = false;
  bool noCellarAlert = false;
  bool cut = false;
  List<int> indexMap = [];
  bool isCut = false;
  ToolsBox toolsBox = ToolsBox();

  Future<void> initManga() async {
    final String? uuid = mHandler.manga?.results?.chapter?.uuid;
    debugPrint("MyVM: initManga, chapter uuid: $uuid");
    if (uuid != null && uuid.isNotEmpty) {
      pn = (await getPreferences()).getInt(uuid) ?? -4;
      debugPrint("MyVM: load pn from uuid: $pn");
    } else {
      pn = -4;
    }
    if (!(await zipFile?.exists() ?? false)) {
      await doPrepareWebImg();
    } else {
      await prepareItems();
    }
    if (!isVertical) {
      restorePN();
    }
  }

  Future<void> prepareImgFromWeb() async {
    if (!noCellarAlert && toolsBox.netInfo == await getString('TRANSPORT_CELLULAR')) {
      alertCellar();
    } else {
      mHandler.startLoad();
    }
  }

  bool canCut(InputStream inputStream) {
    final BitmapFactory.Options options = BitmapFactory.Options();
    options.inJustDecodeBounds = true;
    inputStream.use((stream) {
      BitmapFactory.decodeStream(stream, null, options);
    });
    debugPrint("MyVM: w: ${options.outWidth}, h: ${options.outHeight}");
    return options.outWidth.toFloat() / options.outHeight.toFloat() > 1;
  }

  Future<void> countZipEntries(Function(int) doWhenFinish) async {
    int count = 0;
    if (zipFile != null) {
      try {
        debugPrint("MyVM: zip: $zipFile");
        final zip = ZipFile(zipFile!);
        count = zip.size;
        if (cut) {
          final entries = zip.entries.toList()
            ..sort((a, b) => int.parse(b.name.split('.').first).compareTo(int.parse(a.name.split('.').first)));
          for (int i = 0; i < entries.length; i++) {
            final bool useCut = canCut(zip.getInputStream(entries[i]));
            isCut = isCut || useCut;
            indexMap.add(i + 1);
            if (useCut) {
              indexMap.add(-(i + 1));
            }
            debugPrint("MyVM: [$i] 分析: ${entries[i].name}, cut: $useCut");
          }
        }
      } catch (e) {
        // Handle exception and show error
        await Future.delayed(Duration.zero, () => toolsBox.toastError('count_zip_entries_error'));
      }
    }
    debugPrint("MyVM: 开始加载控件");
    doWhenFinish(count);
  }
}

class MyViewModel {
  int realCount;
  int currentItem;
  bool r2l;
  bool notUseVP;
  bool isVertical;
  int verticalLoadMaxCount;
  PageController vp;
  ScrollController psivs;
  double size;
  Handler mHandler;

  int getPageNumber() {
    return (r2l && !notUseVP) ? realCount - vp.page.round() : 
           (notUseVP ? currentItem : vp.page.round()) + 1;
  }

  void setPageNumber(int pageNumber) {
    Future(() async {
      print("MyVM: setPageNumber($pageNumber)");
      if (r2l && !notUseVP) {
        vp.jumpToPage(realCount - pageNumber);
      } else if (notUseVP) {
        currentItem = pageNumber - 1;
        if (isVertical) {
          var offset = currentItem % verticalLoadMaxCount;
          print("MyVM: Current: $currentItem, Height: ${psivs.position.maxScrollExtent}, scrollY: ${psivs.position.pixels}");
          if (!isInScroll || isInSeek) {
            psivs.jumpTo(psivs.position.pixels * offset / size);
          }
          updateSeekBar();
        } else {
          currentItem = pageNumber - 1;
          try {
            await loadOneImg();
          } catch (e) {
            print(e);
            // Assuming a method to show a toast message is available
            showToastError("Error loading page number: $currentItem");
          }
        }
      } else {
        print("MyVM: Set vp current: ${pageNumber - 1}");
        vp.jumpToPage(pageNumber - 1);
      }
    });
  }

  String getImgUrl(int position) {
    return mHandler.manga?.results?.chapter?.contents
        ?.elementAt(mHandler.manga.results.chapter.words.indexOf(position))?.url;
  }

  List<String?> getImgUrlArray() {
    return mHandler.manga?.results?.chapter?.contents
        ?.map((content) => getImgUrl(content.position))
        ?.toList();
  }

  Bitmap cutBitmap(Bitmap bitmap, bool isEnd) {
    return Bitmap.createBitmap(bitmap, isEnd ? (bitmap.width ~/ 2) : 0, 0, bitmap.width ~/ 2, bitmap.height);
  }

  Future<void> loadImg(ScaleImageView imgView, Bitmap bitmap, bool useCut, bool isLeft, {bool isPlaceholder = true}) async {
    var bitmapToLoad = (!isPlaceholder && useCut) ? cutBitmap(bitmap, isLeft) : bitmap;
    imgView.setImageBitmap(bitmapToLoad);
    if (!isPlaceholder && isVertical) {
      imgView.setHeightToFitImgWidth();
      print("MyVM: Decreasing remaining image count");
      mHandler.sendEmptyMessage(VMHandler.DECREASE_IMAGE_COUNT_AND_RESTORE_PAGE_NUMBER_AT_ZERO);
    }
  }
}

Future<bool> loadImageUrlInto(
    ScaleImageView imageView,
    ElevatedButton button,
    String url,
    bool useCut,
    bool isLeft,
    bool Function()? check) async {
  print("Load from adt: $url");
  bool success = await PausableDownloader(
      CMApi.resolution.wrap(CMApi.imageProxy?.wrap(url) ?? url),
      1000,
      false,
      (Uint8List data) {
        if (check != null && check()) {
          loadImg(imageView, await decodeImageFromList(data), useCut, isLeft, false);
        }
      }).run();
  
  if (!success) {
    button.setState(() {
      button.visibility = true; // Assuming a method to change visibility
    });
  }
  return success;
}

Future<Image> getLoadingBitmap(int position) async {
  final loading = Bitmap(
      width: 1024,
      height: 256,
      config: BitmapConfig.argb8888);
  final canvas = Canvas(loading);
  final paint = Paint()
    ..color = colorOnSurface
    ..textSize = 100.0
    ..typeface = Font.nisiTypeFace;

  String text = "${position + 1}";
  double x = (canvas.width - paint.measureText(text)) / 2;
  double y = (canvas.height + paint.descent() - paint.ascent()) / 2;
  canvas.drawText(text, x, y, paint);
  
  return loading;
}

Future<bool> loadImageOn(ScaleImageView imageView, Button reloadButton, int position, {bool isSingle = false}) async {
  print("Load img: $position");
  
  if (isSingle && position != currentItem) return true;
  if (position < 0 || position > realCount) return false;
  
  int indexToLoad = cut ? (indexMap[position].abs() - 1) : position;
  bool useCut = cut && isCut[indexToLoad];
  bool isLeft = cut && indexMap[position] > 0;

  bool success = zipFile?.existsSync() == true
      ? (getImageBitmap(indexToLoad)?.let((bitmap) {
          loadImage(imageView, bitmap, useCut, isLeft, false);
          return true;
        }) ?? false)
      : await (() async {
          int sleepTime = loadImageOnWait.getAndIncrement() * 200;
          print("loadImgOn sleep: $sleepTime ms");
          var task = tasks?[indexToLoad];
          if (sleepTime > 0 && !(task?.isDone ?? true)) {
            loadImage(imageView, getLoadingBitmap(position), useCut, isLeft, true);
            await Future.delayed(Duration(milliseconds: sleepTime));
            if (isSingle && position != currentItem) return true;
          }
          
          bool result;
          if (task != null) {
            if (!task.isDone) {
              loadImage(imageView, getLoadingBitmap(position), useCut, isLeft, true);
              task.run();
            }
            var data = await task.get();
            if (isSingle && position != currentItem) return true;
            if (data != null && data.isNotEmpty) {
              loadImage(imageView, BitmapFactory.decodeByteArray(data, 0, data.length), useCut, isLeft, false);
              print("Load position $position from task");
              return true;
            } else {
              var url = getImageUrl(indexToLoad);
              if (url != null) {
                loadImage(imageView, getLoadingBitmap(position), useCut, isLeft, true);
                await loadImageUrlInto(imageView, reloadButton, url, useCut, isLeft, () {
                  return !(isSingle && position != currentItem);
                });
                return true;
              }
            }
          } else {
            var url = getImageUrl(indexToLoad);
            if (url != null) {
              loadImage(imageView, getLoadingBitmap(position), useCut, isLeft, true);
              await loadImageUrlInto(imageView, reloadButton, url, useCut, isLeft, () {
                return !(isSingle && position != currentItem);
              });
              return true;
            }
          }
          loadImageOnWait.decrementAndGet();
          if (tasks != null && indexToLoad < tasks.length) {
            int p = (indexToLoad == tasks.length - 1) ? indexToLoad - 1 : indexToLoad + 1;
            int delta = 1;
            bool isMinus = false;
            int pos = p;
            int maxCount = tasks.length;

            while (pos >= 0 && pos < tasks.length && !(tasks[pos]?.isDone ?? false) && !(tasksRunStatus?[pos] ?? false) && maxCount-- > 0) {
              // Additional logic can go here if necessary
              pos += delta; // Adjust pos based on your needs
            }
          }
          return false;
        })();
  
  return success;
}

// Flutter framework is being used for the Dart translation.
void logDebug(String tag, String message) {
  // Implement logging functionality
}

void preloadImages() {
  logDebug("MyVM", "search $position");
  position = p + (isMinus ? -delta : delta);
  if (!indices.contains(position)) {
    isMinus = !isMinus;
    if (!isMinus) delta++;
    position = p + (isMinus ? -delta : delta);
    if (!indices.contains(position)) return;
  }
  isMinus = !isMinus;
  if (!isMinus) delta++;

  if (!indices.contains(position) || (tasksRunStatus != null && tasksRunStatus![position] != false)) return;
  logDebug("MyVM", "Preload position $position from task");
  get(position)?.let((task) {
    if (!task.isDone) {
      tasksRunStatus![position] = true;
      Thread(task).start();
    }
  });
}

Future<void> loadOneImage() async {
  final img = onei;
  oneb.apply(() {
    post(() {
      if (!hasOnClickListeners()) {
        setOnClickListener(() {
          lifecycleScope.launch(() async {
            if (await loadImageOn(img, this, currentItem, true)) {
              post(() {
                visibility = Visibility.GONE;
              });
            }
          });
        });
      }
    });
  });
  await loadImageOn(onei, oneb, currentItem, true);
  updateSeekBar();
}

void initImageList() {
  for (int i = 0; i < verticalLoadMaxCount; i++) {
    final newOneImage = layoutInflater.inflate(R.layout.page_imgview, psivl, false);
    final img = newOneImage.onei;
    final button = newOneImage.oneb;
    final positionIndex = scrollPositions.length;
    button.apply(() {
      post(() {
        setOnClickListener(() {
          lifecycleScope.launch(() async {
            if (await loadImageOn(img, this, scrollPositions[positionIndex])) {
              post(() {
                visibility = Visibility.GONE;
              });
            }
          });
        });
      });
    });
    scrollImages.add(img);
    scrollButtons.add(button);
    scrollPositions.add(-1);
    psivl.addView(newOneImage);
  }
}

// Dart translation of Kotlin code, assuming Flutter framework
void prepareLastPage(int loadCount, int maxCount) {
  for (int index = loadCount; index < maxCount; index++) {
    mHandler.obtainMessage(VMHandler.CLEAR_IMG_ON, scrollImages[index]).sendToTarget();
    scrollButtons[index].apply(() {
      Future.delayed(Duration.zero, () {
        visibility = Visibility.hidden;
      });
    });
  }
  // mHandler.dl?.hide();
}

Future<Bitmap?> getImgBitmap(int position) async {
  if (position >= count || position < 0) return null;

  final zipFile = ZipFile(zipFilePath); // Assume zipFilePath is defined
  Bitmap? bitmap;

  for (int i = 0; i <= 1; i++) {
    String extension = (i == 0 && tryWebpFirst) || (i == 1 && !tryWebpFirst) ? 'webp' : 'jpg';
    try {
      final zipInputStream = zipFile.getInputStream(zipFile.getEntry('$position.$extension'));
      if (zipInputStream != null) {
        bitmap = (q == 100)
            ? BitmapFactory.decodeStream(zipInputStream)
            : await () {
                final output = ByteArrayOutputStream();
                BitmapFactory.decodeStream(zipInputStream)?.compress(Bitmap.CompressFormat.jpeg, q, output);
                return BitmapFactory.decodeStream(ByteArrayInputStream(output.toByteArray()));
              }();
      }
    } catch (e) {
      if (i == 1) {
        print(e);
        await Future.delayed(Duration.zero, () {
          Toast.show('加载zip的第${position}项错误', context); // Assume context is defined
        });
      }
      bitmap = null;
    }
    if (bitmap != null) {
      tryWebpFirst = extension == 'webp';
      break;
    }
  }
  return bitmap;
}

void setIdPosition(int position) {
  double infoDrawerDelta = position.toDouble();
  infcard.translationY = infoDrawerDelta;
  debugPrint("Set info drawer delta to $infoDrawerDelta");
  mHandler.sendEmptyMessage(fullyHideInfo ? 16 : VMHandler.HIDE_INFO_CARD);
}

@experimental
Future<void> prepareItems() async {
  try {
    await prepareVP();
    await prepareInfoBar();
    await prepareIdBtVH();
    int? position = toolsBox.dp2px(fullyHideInfo ? 100 : 67);
    if (position != null) {
      setIdPosition(position);
    }
    await prepareIdBtCut();
    await prepareIdBtVP();
    await prepareIdBtLR();
    if (!notUseVP && !isVertical && !isPnValid) loadOneImg();
    /*progressLog?.let((it) {
      it["chapterId"] = hm.chapterId.toString();
      it["name"] = inftitle.ttitle.text;
    });*/
  } catch (e) {
    print(e);
    toolsBox.toastError(R.string.load_chapter_error);
    finish();
  }
}

Future<void> setProgress() async {
  String? uuid = mHandler.manga?.results?.chapter?.uuid;
  if (uuid != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("chapterId", hm.chapterId.toString());
    prefs.setInt(uuid, pageNum);
    // prefs.setString("name", inftitle.ttitle.text);
  }
}

void fadeRecreate() {
  ObjectAnimator oa = ObjectAnimator.ofFloat(vcp, "alpha", 1.0, 0.1);
  oa.duration = Duration(milliseconds: 1000);
  oa.addListener(() {
    if (oa.isFinished) {
      onecons?.clear();
      psivl?.clear();
      recreate();
    }
  });
  oa.start();
}

void prepareIdBtCut() {
  idtbcut.isChecked = cut;
  idtbcut.onClick((_) {
    pb["useCut"] = idtbcut.isChecked;
    fadeRecreate();
  });
}

// Dart code for Flutter framework

void prepareIdButtonLeftRight() {
  idTableLeftRight.isChecked = rightToLeft;
  idTableLeftRight.onClick = () {
    if (isVertical) {
      showToast(context, 'Unsupported mode switching');
      return;
    }
    progressBar["r2l"] = idTableLeftRight.isChecked;
    fadeRecreate();
  };
}

void prepareIdButtonVertical() {
  idTableVertical.isChecked = notUseVertical;
  idTableVertical.onClick = () {
    if (isVertical) {
      showToast(context, 'Unsupported mode switching');
      return;
    }
    progressBar["noVP"] = idTableVertical.isChecked;
    fadeRecreate();
  };
}

void prepareVerticalPanel() {
  if (notUseVertical) {
    verticalPanel.visibility = Visibility.hidden;
    if (!isVertical) oneVisibility.visibility = Visibility.visible;
  } else {
    verticalPanel.visibility = Visibility.visible;
    oneVisibility.visibility = Visibility.hidden;
    verticalPanel.adapter = ViewData(verticalPanel).RecyclerViewAdapter();
    verticalPanel.registerOnPageChangeCallback(PageChangeCallback((int position) {
      updateSeekBar();
    }));
    if (rightToLeft && !isPageNumberValid) verticalPanel.currentItem = realCount - 1;
  }
}

Future<void> updateSeekBar([int position = 0]) async {
  if (position > 0) {
    updateSeekText(position);
    return;
  }
  if (!isInSeek) hideDrawer();
  updateSeekText();
  updateSeekProgress();
  setProgress();
}

// Flutter framework usage
void prepareInfoBar() {
  oneInfo.alpha = 0.0;
  infSeek.visibility = Visibility.hidden;
  isearch.visibility = Visibility.hidden;
  inftitle.ttitle.text = "$comicName ${mHandler.manga?.results?.chapter?.name}";
  infTxtProgress.text = "$pageNum/$realCount";
  infSeek.onSeekBarChangeListener = new SeekBarOnChangeListener();

  isearch.setImageResource(R.drawable.ic_author);
  isearch.onClick = () {
    mHandler.sendEmptyMessage(
        fullyHideInfo ? VMHandler.TRIGGER_INFO_CARD_FULL : VMHandler.TRIGGER_INFO_CARD); // trigger info card
  };
}

class SeekBarOnChangeListener implements SeekBar.OnSeekBarChangeListener {
  int progress = 0;
  int manualCount = 0;
  int startProgress = 0;

  @override
  void onProgressChanged(SeekBar seekBar, int progressValue, bool isHuman) {
    if (isHuman) {
      int newProgress = (progressValue * realCount / 100).toInt();
      if (newProgress <= 0) newProgress = 1;
      else if (newProgress > realCount) newProgress = realCount;
      print("MyVM: seek to $newProgress");
      if (progressValue >= (pageNum + 1) * 100 / realCount) {
        if (manualCount < 3) {
          scrollForward();
        } else {
          progress = newProgress;
        }
        after();
      } else if (progressValue < (pageNum - 1) * 100 / realCount) {
        if (manualCount < 3) {
          scrollBack();
        } else {
          progress = newProgress;
        }
        after();
      }
    }
  }

  @override
  void onStartTrackingTouch(SeekBar seekBar) {
    isInSeek = true;
    progress = pageNum;
    startProgress = progress;
    manualCount = 0;
  }

  @override
  void onStopTrackingTouch(SeekBar seekBar) {
    if (manualCount >= 3) {
      int stoppedProgress = progress;
      print("MyVM: stop seek at $stoppedProgress");
      if (isVertical && startProgress ~/ verticalLoadMaxCount != progress ~/ verticalLoadMaxCount) {
        mHandler.obtainMessage(
          VMHandler.LOAD_ITEM_SCROLL_MODE,
          (progress ~/ verticalLoadMaxCount) * verticalLoadMaxCount,
          0,
          () {
            isInScroll = false;
            forceLetPNValid = true;
            pn = stoppedProgress;
            print("MyVM: set stopped seek to $stoppedProgress = $pageNum");
            isInSeek = false;
          },
        ).sendToTarget();
      } else {
        pageNum = stoppedProgress;
      }
    } else {
      isInSeek = false;
    }
  }

  void after() {
    if (manualCount++ < 3) {
      progress = pageNum;
    } else {
      lifecycleScope.launch(() => updateSeekBar(progress));
    }
  }
}

// Flutter framework code
@ExperimentalStdlibApi
void prepareIdBtVH() {
  idtbvh.isChecked = isVertical;
  final pagesManager = PagesManager(WeakReference(this));
  if (isVertical) {
    (vsp as SpringView).apply((springView) {
      springView.footerView.lht.setText(R.string.button_more);
      springView.headerView.lht.setText(R.string.button_more);
      springView.setListener(SpringView.OnFreshListener(
        onLoadmore: () {
          //scrollForward()
          pagesManager?.toPage(true);
          onFinishFreshAndLoad();
        },
        onRefresh: () {
          //scrollBack()
          pagesManager?.toPage(false);
          onFinishFreshAndLoad();
        },
      ));
    });
    vp.visibility = View.GONE;
    vsp.visibility = View.VISIBLE;
    initImgList();
    mHandler.sendEmptyMessage(isPnValid ? VMHandler.LOAD_PAGE_FROM_ITEM : VMHandler.LOAD_SCROLL_MODE);
    psivs.setOnScrollChangeListener((_, __, scrollY, ___, ____) {
      isInScroll = true;
      if (!isInSeek) {
        final delta = (scrollY.toFloat() * size.toFloat() / psivl.height.toFloat() + 0.5).toInt() - currentItem % verticalLoadMaxCount;
        if (delta != 0 && !(delta > 0 && pageNum == size)) {
          final fin = pageNum + delta;
          pageNum = (fin <= 0)
              ? 1
              : (fin % verticalLoadMaxCount == 0)
                  ? fin ~/ verticalLoadMaxCount * verticalLoadMaxCount
                  : fin;
          Log.d("MyVM", "Scroll to offset $delta, page $pageNum");
        }
      }
    });
  }
  idtbvh.setOnClickListener(() {
    pb["vertical"] = idtbvh.isChecked;
    fadeRecreate();
  });
}

void scrollBack() {
  isInScroll = false;
  if (isVertical && (pageNum - 1) % verticalLoadMaxCount == 0) {
    Log.d("MyVM", "Do scroll back, isVertical: $isVertical, pageNum: $pageNum");
    if (isInSeek) {
      (pageNum - 1).let((it) {
        lifecycleScope.launch(() => updateSeekBar(it));
      });
      return;
    }
    mHandler.obtainMessage(
      VMHandler.LOAD_ITEM_SCROLL_MODE,
      currentItem - verticalLoadMaxCount,
      0,
      () {
        forceLetPNValid = true;
        pn = pageNum - 1;
      },
    ).sendToTarget(); //loadImgsIntoLine(currentItem - verticalLoadMaxCount)
  } else {
    pageNum--;
  }
}

// Flutter framework

void scrollForward() {
  isInScroll = false;
  pageNum++;
  if (isVertical && (pageNum - 1) % verticalLoadMaxCount == 0) {
    if (isInSeek) {
      (pageNum + 1).let((nextPageNum) {
        lifecycleScope.launch(() {
          updateSeekBar(nextPageNum);
        });
      });
      return;
    }
    mHandler.sendEmptyMessage(VMHandler.LOAD_SCROLL_MODE);
  }
}

void updateSeekText([int p = 0]) {
  inftxtprogress.text = "${p == 0 ? pageNum : p}/$realCount";
}

void updateSeekProgress() {
  infseek.progress = (pageNum * 100 / realCount).toInt();
}

@override
void onDestroy() {
  dlHandler?.sendEmptyMessage(0);
  tt.canDo = false;
  destroy = true;
  dlHandler = null;
  mHandler.dl.dismiss();
  mHandler.destroy();
  super.onDestroy();
}

class ViewData extends RecyclerView.ViewHolder {
  ViewData(View itemView) : super(itemView);

  class RecyclerViewAdapter extends RecyclerView.Adapter<ViewData> {
    @override
    ViewData onCreateViewHolder(ViewGroup parent, int viewType) {
      return ViewData(
        LayoutInflater.from(parent.context)
            .inflate(R.layout.page_imgview, parent, false),
      );
    }
  }
}

class YourAdapter extends StatelessWidget {
  // Define your variables here
  final int realCount;
  final bool r2l;
  final bool cut;
  final List<int> indexMap;
  final List<bool> isCut;
  final File? zipFile;

  YourAdapter({
    required this.realCount,
    required this.r2l,
    required this.cut,
    required this.indexMap,
    required this.isCut,
    this.zipFile,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: realCount,
      itemBuilder: (context, position) {
        return buildViewHolder(context, position);
      },
    );
  }

  Widget buildViewHolder(BuildContext context, int position) {
    final pos = r2l ? realCount - position - 1 : position;
    final indexToLoad = cut ? (indexMap[pos].abs() - 1) : pos;
    final useCut = cut && isCut[indexToLoad];
    final isLeft = cut && indexMap[pos] > 0;

    if (zipFile?.existsSync() == true) {
      // Load bitmap from local zip file
      loadImgBitmap(indexToLoad).then((bitmap) {
        if (bitmap != null) {
          // Set image
          setImage(bitmap, useCut, isLeft);
        }
      });
    } else {
      loadImgUrl(indexToLoad).then((url) {
        if (url != null) {
          if (useCut) {
            // Load image as bitmap with cut
            loadImageWithCut(url, isLeft);
          } else {
            // Load image normally
            loadImageNormally(url);
          }
        }
      });
    }

    return Container(); // Replace with your actual UI element
  }

  void setImage(Bitmap bitmap, bool useCut, bool isLeft) {
    // Set the image to the widget
  }

  Future<Bitmap?> loadImgBitmap(int index) async {
    // Implement your bitmap loading logic
    return null; // Replace with actual bitmap
  }

  Future<String?> loadImgUrl(int index) async {
    // Implement your image URL loading logic
    return null; // Replace with actual URL
  }

  void loadImageWithCut(String url, bool isLeft) {
    // Your logic to load image with cut
  }

  void loadImageNormally(String url) {
    // Your logic to load image normally
  }

  int getItemCount() {
    return realCount;
  }
}

class OneButtonRequestListener<T> {
  final Button button;

  OneButtonRequestListener(this.button) {
    button.onPressed = () {
      // Your button click logic
    };
  }

  void onLoadFailed(Exception e) {
    button.visibility = true; // Show button on load fail
  }

  void onResourceReady(T resource) {
    button.visibility = false; // Hide button on resource ready
  }
}

// Flutter framework
void showDrawer() {
  clicked = 2; // loading
  infseek.post(() {
    infseek.visibility = View.VISIBLE;
    isearch.post(() {
      isearch.visibility = View.VISIBLE;
      infseek.invalidate();
      isearch.invalidate();
      ObjectAnimator.ofFloat(
        oneinfo,
        "alpha",
        oneinfo.alpha,
        1.0,
      ).setDuration(300).start();
      clicked = 1; // true
    });
  });
}

void hideDrawer() {
  clicked = 2; // loading
  ObjectAnimator.ofFloat(
    oneinfo,
    "alpha",
    oneinfo.alpha,
    0.0,
  ).setDuration(300).start();
  infseek.postDelayed(() {
    infseek.visibility = View.GONE;
    isearch.visibility = View.GONE;
    infseek.invalidate();
    isearch.invalidate();
    clicked = 0; // false
  }, 300);
  mHandler.sendEmptyMessage(fullyHideInfo ? VMHandler.HIDE_INFO_CARD_FULL : VMHandler.HIDE_INFO_CARD);
}

class Companion {
  static Handler? dlHandler;
  static WeakReference<ViewMangaActivity>? va;
  static bool noCellarAlert = false;
}


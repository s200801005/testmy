import 'dart:ui';
import 'package:copyswdkui2/ui/comicdl/ComicDlFragment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  Menu? menuMain;
  NavController? navController;
  late AppBarConfiguration appBarConfiguration;
  late File headPic;
  late UITools toolsBox;
  bool isMenuWaiting = false;

  @override
  void initState() {
    super.initState();
    mainWeakReference = WeakReference(this);
    toolsBox = UITools(this);

    setContentView(R.layout.activity_main);
    setSupportActionBar(toolbar);
    coordiv.layoutParams.height = UITools.getStatusBarHeight(this);

    navController = findNavController(R.id.nav_host_fragment);
    appBarConfiguration = AppBarConfiguration(
      setOf(
        R.id.nav_home,
        R.id.nav_sort,
        R.id.nav_rank,
        R.id.nav_sub,
        R.id.nav_history,
        R.id.nav_new_download,
        R.id.nav_settings,
      ),
      drawer_layout,
    );
    setupActionBarWithNavController(navController!, appBarConfiguration);
    nav_view.setupWithNavController(navController!);

    headPic = File(getExternalFilesDir(""), "headPic");
    drawer_layout.addDrawerListener(object : DrawerLayout.DrawerListener {
      @override
      void onDrawerClosed(View drawerView) {
        Log.d("MyMain", "onDrawerClosed");
        isDrawerClosed = true;
      }

      @override
      void onDrawerOpened(View drawerView) {
        Log.d("MyMain", "onDrawerOpened");
        isDrawerClosed = false;
        lifecycleScope.launch {
          withContext(Dispatchers.IO) {
            refreshUserInfo();
          }
        }
      }

      @override
      void onDrawerSlide(View drawerView, float slideOffset) {}

      @override
      void onDrawerStateChanged(int newState) {}
    });
    goCheckUpdate(false);

    ime = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager;

    var latestDestination;
    navController!.addOnDestinationChangedListener { _, destination, _ ->
      latestDestination = destination.id;
      Log.d("MyMA", "latestDestination: $latestDestination");
      if (isMenuWaiting) {
        return@addOnDestinationChangedListener;
      }
      isMenuWaiting = true;
      Log.d("MyMA", "start menu waiting");
      lifecycleScope.launch {
        withContext(Dispatchers.IO) {
          delay(1000);
          withContext(Dispatchers.Main) {
            isMenuWaiting = false;
            Log.d("MyMA", "finish menu waiting");
            changeMenuList(latestDestination);
          }
        }
      }
    };
  }

  @override
  void onPostCreate(Bundle? savedInstanceState) {
    super.onPostCreate(savedInstanceState);
    PreferenceManager.getDefaultSharedPreferences(this)?.apply {
      if (contains("settings_cat_general_sb_startup_menu"))
        getString("settings_cat_general_sb_startup_menu", "0")?.toInt()?.let {
          if (it > 0) {
            Log.d("MyMain", "nav 2 dest $it");
            navController!.navigate(listOf(
              R.id.nav_home,
              R.id.nav_sort,
              R.id.nav_rank,
              R.id.nav_sub,
              R.id.nav_history,
              R.id.nav_new_download,
              R.id.nav_settings,
            )[it]);
          }
        };
      if (getBoolean("settings_cat_general_sw_enable_transparent_systembar", false)) {
        WindowCompat.setDecorFitsSystemWindows(window, false);
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        window.statusBarColor = 0;
        window.navigationBarColor = 0;
      }
    };
  }

  @override
  bool onCreateOptionsMenu(Menu menu) {
    // Inflate the menu; this adds items to the action bar if it is present.
    menuInflater.inflate(R.menu.main, menu);
    menuMain = menu;
    return true;
  }
}

@override
bool onOptionsItemSelected(MenuItem item) {
  switch (item.itemId) {
    case R.id.action_info:
      showAbout();
      return true;
    case R.id.action_download:
      bookHandler.get()?.sendEmptyMessage(6);
      return true;
    case R.id.action_sort:
      ComicDlFragment.handler?.sendEmptyMessage(13);
      NewDownloadFragment.wn?.get()?.showReverseInfo(toolsBox);
      RankFragment.wr?.get()?.showSexInfo(toolsBox);
      return true;
    case R.id.action_del:
      if (DownloadFragment.wd != null) {
        AlertDialog dialog = AlertDialog(
          content: Text(R.string.delele_all_empty_manga),
          actions: [
            TextButton(
              child: Text(android.R.string.ok),
              onPressed: () {
                DownloadFragment.wd?.get()?.removeAllEmpty();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
        showDialog(context: context, builder: (context) => dialog);
      }
      return true;
    default:
      return super.onOptionsItemSelected(item);
  }
}

@override
bool onSupportNavigateUp() {
  final navController = findNavController(R.id.nav_host_fragment);

  checkHeadPicture();
  if (headPic.exists()) {
    navhbg.onLongPress = () {
      if (headPic.exists()) {
        AlertDialog dialog = AlertDialog(
          content: Text(R.string.clearHeadImgMsg),
          actions: [
            TextButton(
              child: Text(android.R.string.ok),
              onPressed: () {
                if (headPic.exists()) headPic.delete();
                navhbg.setImageResource(R.drawable.illust_57793944_20190427_134853);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
        showDialog(context: context, builder: (context) => dialog);
      }
      return true;
    };
  }
  navtinfo.text = getPreferences(MODE_PRIVATE).getString("navTextInfo", getString(R.string.navTextInfo));
  return navController.navigateUp(appBarConfiguration) || super.onSupportNavigateUp();
}

// This Dart code is generated from Kotlin source code.
@override
void onRequestPermissionsResult(int requestCode, List<String?> permissions, List<int> grantResults) {
  super.onRequestPermissionsResult(requestCode, permissions, grantResults);
  switch (requestCode) {
    case MSG_CROP_IMAGE:
      if (grantResults.isNotEmpty && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        pickPicture();
      } else {
        Toast.show(context, R.string.permissionDenied, duration: Toast.LENGTH_SHORT);
      }
      break;
  }
}

Future<void> refreshUserInfo() async {
  final preferences = await SharedPreferences.getInstance();
  if (preferences != null) {
    final String name = preferences.getString("nickname") ?? preferences.getString("username") ?? "";
    final String avatar = preferences.getString("avatar") ?? "";
    navttitle.post(() {
      if (name.isNotEmpty) {
        navttitle.text = name;
      } else {
        navttitle.setText(R.string.noLogin);
      }
    });
    navhicon.post(() {
      if (avatar.isNotEmpty) {
        Glide.with(context).load(avatar)
          .apply(RequestOptions.bitmapTransform(CircleCrop()))
          .timeout(Duration(seconds: 60))
          .into(navhicon);
      } else {
        navhicon.setImageResource(R.mipmap.ic_launcher);
      }
    });
  }
}

void changeMenuList(int latestDestination) {
  switch (latestDestination) {
    case R.id.nav_home:
      Log.d("MyMA", "enter home");
      menuMain?.findItem(R.id.action_info)?.isVisible = true;
      menuMain?.findItem(R.id.action_download)?.isVisible = false;
      menuMain?.findItem(R.id.action_sort)?.isVisible = false;
      menuMain?.findItem(R.id.action_del)?.isVisible = false;
      break;
    case R.id.nav_book:
      Log.d("MyMA", "enter book");
      menuMain?.findItem(R.id.action_info)?.isVisible = false;
      menuMain?.findItem(R.id.action_download)?.isVisible = true;
      menuMain?.findItem(R.id.action_sort)?.isVisible = false;
      menuMain?.findItem(R.id.action_del)?.isVisible = false;
      break;
    case R.id.nav_group:
      Log.d("MyMA", "enter group");
      menuMain?.findItem(R.id.action_info)?.isVisible = false;
      menuMain?.findItem(R.id.action_download)?.isVisible = false;
      menuMain?.findItem(R.id.action_sort)?.isVisible = true;
      menuMain?.findItem(R.id.action_del)?.isVisible = false;
      break;
    case R.id.nav_new_download:
      Log.d("MyMA", "enter new_download");
      menuMain?.findItem(R.id.action_info)?.isVisible = false;
      menuMain?.findItem(R.id.action_download)?.isVisible = false;
      menuMain?.findItem(R.id.action_sort)?.isVisible = true;
      menuMain?.findItem(R.id.action_del)?.isVisible = false;
      break;
    case R.id.nav_rank:
      Log.d("MyMA", "enter rank");
      menuMain?.findItem(R.id.action_info)?.isVisible = false;
      menuMain?.findItem(R.id.action_download)?.isVisible = false;
      menuMain?.findItem(R.id.action_sort)?.isVisible = true;
      menuMain?.findItem(R.id.action_del)?.isVisible = false;
      break;
    case R.id.nav_download:
      Log.d("MyMA", "enter old download");
      menuMain?.findItem(R.id.action_info)?.isVisible = false;
      menuMain?.findItem(R.id.action_download)?.isVisible = false;
      menuMain?.findItem(R.id.action_sort)?.isVisible = false;
      menuMain?.findItem(R.id.action_del)?.isVisible = true;
      break;
    default:
      Log.d("MyMA", "enter others");
      menuMain?.findItem(R.id.action_info)?.isVisible = false;
      menuMain?.findItem(R.id.action_download)?.isVisible = false;
      menuMain?.findItem(R.id.action_sort)?.isVisible = false;
      menuMain?.findItem(R.id.action_del)?.isVisible = false;
      break;
  }
}

class MainActivity extends StatefulWidget {
  @override
  _MainActivityState createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  late File headPicture;
  late ImagePicker imagePicker;

  @override
  void initState() {
    super.initState();
    headPicture = File(''); // Initialize with an empty path
    imagePicker = ImagePicker();
  }

  Future<bool> checkReadPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  void pickPicture() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      saveFile(File(pickedFile.path));
      cropImageUri();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image')));
    }
  }

  void saveFile(File uri) {
    uri.copy(headPicture.path);
  }

  void checkHeadPicture() {
    if (headPicture.existsSync()) {
      setState(() {
        // Assuming navhbg is an Image widget to display the image
        // Update the UI to show the head picture
      });
    }
  }

  void cropImageUri() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: headPicture.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepPurple,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
    );
    if (croppedFile != null) {
      setState(() {
        headPicture = File(croppedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cropping image')));
    }
  }

  void goCheckUpdate(bool ignoreSkip) {
    // Implement the update check logic here
  }
}

// Framework: Flutter

void showAbout() {
  final alertDialog = AlertDialog(
    content: Text(AppLocalizations.of(context)!.app_description),
    title: Text('${AppLocalizations.of(context)!.action_info} ${BuildConfig.VERSION_NAME}'),
    icon: Image.asset('assets/ic_launcher.png'),
    actions: [
      TextButton(
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
        onPressed: () {},
      ),
      TextButton(
        child: Text(AppLocalizations.of(context)!.check_update),
        onPressed: () {
          goCheckUpdate(true);
        },
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alertDialog;
    },
  );
}

void onNavTInfoClicked(BuildContext context, TextView textView) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.navTextInfoInputHint),
        content: TextField(
          controller: TextEditingController(text: textView.text),
          onChanged: (charSequence) {
            textView.text = charSequence;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString("navTextInfo", charSequence);
            });
          },
        ),
        actions: [
          TextButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void onNavHBgClicked(BuildContext context, dynamic view) {
  if (checkReadPermission()) {
    pickPicture();
  }
}

void startLoginActivity(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginActivity()),
  );
}

class MainActivity {
  static WeakReference<MainActivity>? mainWeakReference;
  static bool isDrawerClosed = true;
  static InputMethodManager? ime;
  static const int MSG_CROP_IMAGE = 1;
  static Shelf? shelf;

  static Shelf? getShelf() {
    if (shelf != null) return shelf;
    final activity = mainWeakReference?.get();
    if (activity != null) {
      shelf = Shelf(
        activity.getPreferences(MODE_PRIVATE)!.getString("token", "") ?? '',
        (id) => activity.getString(id),
      );
      return shelf;
    }
    return null;
  }

  static Member? member;

  static Member? getMember() {
    if (member != null) return member;
    final activity = mainWeakReference?.get();
    if (activity != null) {
      final prefs = activity.getPreferences(MODE_PRIVATE);
      member = Member(prefs, (id) => activity.getString(id));
      return member;
    }
    return null;
  }
}

class BuildConfig {
  static String get VERSION_NAME {
    throw UnimplementedError();
  }
}

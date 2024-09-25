import 'dart:ui';

import 'package:copyswdkui2/ui/comicdl/ComicDlFragment.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

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
    headPic = File(getExternalFilesDir(""), "headPic");
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

    drawer_layout.addDrawerListener(DrawerListener(
      onDrawerClosed: (drawerView) {
        Log.d("MyMain", "onDrawerClosed");
        isDrawerClosed = true;
      },
      onDrawerOpened: (drawerView) {
        Log.d("MyMain", "onDrawerOpened");
        isDrawerClosed = false;
        lifecycleScope.launch(() async {
          await withContext(Dispatchers.IO, refreshUserInfo);
        });
      },
      onDrawerSlide: (drawerView, slideOffset) {},
      onDrawerStateChanged: (newState) {},
    ));
    goCheckUpdate(false);

    ime = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager;

    navController!.addOnDestinationChangedListener((_, destination, _) {
      latestDestination = destination.id;
      Log.d("MyMA", "latestDestination: $latestDestination");
      if (isMenuWaiting) {
        return;
      }
      isMenuWaiting = true;
      Log.d("MyMA", "start menu waiting");
      lifecycleScope.launch(() async {
        await withContext(Dispatchers.IO, () async {
          await Future.delayed(Duration(seconds: 1));
          await withContext(Dispatchers.Main, () {
            isMenuWaiting = false;
            Log.d("MyMA", "finish menu waiting");
            changeMenuList(latestDestination);
          });
        });
      });
    });
  }

  @override
  void onPostCreate(Bundle? savedInstanceState) {
    super.onPostCreate(savedInstanceState);
    PreferenceManager.getDefaultSharedPreferences(this).apply((prefs) {
      if (prefs.contains("settings_cat_general_sb_startup_menu")) {
        prefs.getString("settings_cat_general_sb_startup_menu", "0")?.toInt()?.let((it) {
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
        });
      }
      if (prefs.getBoolean("settings_cat_general_sw_enable_transparent_systembar", false)) {
        WindowCompat.setDecorFitsSystemWindows(window, false);
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        window.statusBarColor = 0;
        window.navigationBarColor = 0;
      }
    });
  }

  @override
  bool onCreateOptionsMenu(Menu menu) {
    menuInflater.inflate(R.menu.main, menu);
    menuMain = menu;
    return true;
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
          val dl = AlertDialog.Builder(this);
          dl.setMessage(R.string.delele_all_empty_manga);
          dl.setPositiveButton(android.R.string.ok, (_, _) {
            DownloadFragment.wd?.get()?.removeAllEmpty();
          });
          dl.show();
        }
        return true;
      default:
        return super.onOptionsItemSelected(item);
    }
  }

  @override
  bool onSupportNavigateUp() {
    val navController = findNavController(R.id.nav_host_fragment);

    checkHeadPicture();
    if (headPic.exists()) navhbg.setOnLongClickListener((_) {
      if (headPic.exists()) {
        val dl = AlertDialog.Builder(this);
        dl.setMessage(R.string.clearHeadImgMsg);
        dl.setPositiveButton(android.R.string.ok, (_, _) {
          if (headPic.exists()) headPic.delete();
          navhbg.setImageResource(R.drawable.illust_57793944_20190427_134853);
        });
        dl.show();
      }
      return true;
    });
    navtinfo.text = getPreferences(MODE_PRIVATE).getString("navTextInfo", getString(R.string.navTextInfo));
    return navController.navigateUp(appBarConfiguration) || super.onSupportNavigateUp();
  }

  @override
  void onRequestPermissionsResult(int requestCode, Array<String?> permissions, IntArray grantResults) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    when (requestCode) {
      MSG_CROP_IMAGE -> {
      if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) pickPicture();
      else Toast.makeText(this, R.string.permissionDenied, Toast.LENGTH_SHORT).show();
      }
    }
  }

  Future<void> refreshUserInfo() async {
    getPreferences(MODE_PRIVATE)?.apply((prefs) {
      val name = prefs.getString("nickname", prefs.getString("username", ""));
      val avatar = prefs.getString("avatar", "");
      navttitle.apply { post((_) {
        if (name != "") text = name;
        else setText(R.string.noLogin);
      }) };
      navhicon.apply((ic) { post((_) {
        if (avatar != "")
          Glide.with(this@MainActivity).load(avatar)
            .apply(RequestOptions.bitmapTransform(CircleCrop()))
            .timeout(60000)
            .into(this@ic);
        else setImageResource(R.mipmap.ic_launcher);
      }) });
    });
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

  bool checkReadPermission() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N && ContextCompat.checkSelfPermission(
      this,
      Manifest.permission.READ_EXTERNAL_STORAGE,
    ) != PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(
        this,
        arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
        MSG_CROP_IMAGE,
      );
      return false;
    }
    return true;
  }

  var pickerLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult(), (result) {
    if (result.resultCode == Activity.RESULT_OK) result.data?.data?.let((it) {
      saveFile(it);
      cropImageUri();
    });
    else Toast.makeText(this, R.string.err_pick_img, Toast.LENGTH_SHORT).show();
  });

  @SuppressLint("IntentReset")
  void pickPicture() {
    val i = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
    i.type = "image/*";
    pickerLauncher.launch(i);
  }

  void saveFile(Uri uri) {
    contentResolver.openFileDescriptor(uri, "r")?.use((it) {
      it.fileDescriptor?.let((fd) {
        FileInputStream(fd).use((fi) {
          headPic.outputStream().use((fo) {
            fi.copyTo(fo);
          });
        });
      });
    });
  }

  void checkHeadPicture() {
    if (headPic.exists()) navhbg.setImageURI(headPic.toUri());
  }

  var cropLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult(), (result) {
    if (result.resultCode == Activity.RESULT_OK) {
      headPic.inputStream().use((fi) {
        navhbg.setImageBitmap(BitmapFactory.decodeStream(fi));
      });
    } else Toast.makeText(this, R.string.err_crop_img, Toast.LENGTH_SHORT).show();
  });

  void cropImageUri() {
    val op = UCrop.Options();
    val r = navhbg.width.toFloat() / navhbg.height.toFloat();
    Log.d("MyMain", "Img info: (${navhbg.width}, ${navhbg.height})");
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      op.setCompressionFormat(Bitmap.CompressFormat.WEBP_LOSSY);
    } else {
      op.setCompressionFormat(Bitmap.CompressFormat.WEBP);
    }
    op.setStatusBarColor(resources.getColor(R.color.colorPrimaryDark, theme));
    op.setToolbarColor(resources.getColor(R.color.colorPrimary, theme));
    op.setActiveControlsWidgetColor(resources.getColor(R.color.colorAccent, theme));
    cropLauncher.launch(UCrop.of(headPic.toUri(), headPic.toUri())
        .withAspectRatio(r, 1F)
        .withMaxResultSize(navhbg.width, navhbg.height)
        .withOptions(op)
        .getIntent(this));
  }

  void goCheckUpdate(bool ignoreSkip) {
    lifecycleScope.launch(() {
      Update.checkUpdate(this@MainActivity, toolsBox, ignoreSkip);
    });
  }

  void showAbout() {
    val dl = android.app.AlertDialog.Builder(this);
    dl.setMessage(R.string.app_description);
    dl.setTitle("${getString(R.string.action_info)} ${BuildConfig.VERSION_NAME}");
    dl.setIcon(R.mipmap.ic_launcher);
    dl.setPositiveButton(android.R.string.ok, (_, _) {});
    dl.setNeutralButton(R.string.check_update, (_, _) {
      goCheckUpdate(true);
    });
    dl.show();
  }

  @SuppressLint("CheckResult")
  void onNavTInfoClicked(View it) {
    MaterialDialog(this).show((_) {
      input(prefill: (it as TextView).text) { _, charSequence ->
      it.text = charSequence;
      getPreferences(MODE_PRIVATE).edit((_) {
      putString("navTextInfo", charSequence.toString());
      apply();
      });
      };
      positiveButton(android.R.string.ok);
      title(R.string.navTextInfoInputHint);
    });
  }

  void onNavHBgClicked(View v) {
    if (checkReadPermission()) pickPicture();
  }

  void startLoginActivity(View v) {
    startActivity(Intent(this, LoginActivity::class.java));
  }

  companion object {
  var mainWeakReference: WeakReference<MainActivity>? = null;
  var isDrawerClosed = true;
  var ime: InputMethodManager? = null;
  const val MSG_CROP_IMAGE = 1;
  var shelf: Shelf? = null;
  get() {
  if (field != null) return field;
  return mainWeakReference?.get()?.let((it) {
  field = Shelf(
  it.getPreferences(Context.MODE_PRIVATE)
      .getString("token", "") ?: return@let null,
  ) { id ->
  return@Shelf it.getString(id);
  };
  field;
  });
  };
  var member: Member? = null;
  get() {
  if (field != null) return field;
  return mainWeakReference?.get()?.let((it) {
  it.getPreferences(MODE_PRIVATE)?.let((pref) {
  field = Member(pref) { id ->
  return@Member it.getString(id);
  };
  });
  field;
  });
  };
}
}


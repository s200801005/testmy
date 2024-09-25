import 'dart:ui';

import 'package:copyswdkui2/ui/comicdl/ComicDlFragment.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

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
    goCheckUpdate(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Activity'),
      ),
      body: DrawerLayout(
        child: Navigator(
          key: navController,
          onGenerateRoute: (RouteSettings settings) {
            // Define your routes here
          },
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Handle item tap
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  // Handle item tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goCheckUpdate(bool ignoreSkip) {
    // Implement update check logic
  }

  void showAbout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Text('App Description'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Check Update'),
              onPressed: () {
                goCheckUpdate(true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onNavTInfoClicked(View it) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Text'),
          content: TextField(
            onChanged: (value) {
              // Handle text input
            },
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onNavHBgClicked(View v) {
    if (checkReadPermission()) {
      pickPicture();
    }
  }

  void startLoginActivity(View v) {
    // Implement login activity start logic
  }

  bool checkReadPermission() {
    // Implement permission check logic
    return true;
  }

  void pickPicture() {
    final ImagePicker _picker = ImagePicker();
    _picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
      if (pickedFile != null) {
        saveFile(pickedFile.path);
        cropImageUri();
      } else {
        // Handle error
      }
    });
  }

  void saveFile(String path) {
    final file = File(path);
    final newFile = await file.copy(headPic.path);
    // Handle file save
  }

  void cropImageUri() {
    // Implement image cropping logic
  }

  void changeMenuList(int latestDestination) {
    // Implement menu list change logic
  }

  Future<void> refreshUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('nickname') ?? prefs.getString('username') ?? '';
    String avatar = prefs.getString('avatar') ?? '';
    setState(() {
      if (name.isNotEmpty) {
        // Update UI with name
      } else {
        // Update UI with no login message
      }
      if (avatar.isNotEmpty) {
        // Update UI with avatar
      } else {
        // Update UI with default avatar
      }
    });
  }

  String getExternalFilesDir(String type) {
    // Implement external files directory logic
    return '';
  }

  void checkHeadPicture() {
    if (headPic.existsSync()) {
      // Update UI with head picture
    }
  }
}

class UITools {
  final _MainActivityState context;

  UITools(this.context);

  // Implement UITools methods
}

class NavController {
  // Implement NavController methods
}

class AppBarConfiguration {
  // Implement AppBarConfiguration methods
}

class WeakReference<T> {
  T? _value;

  WeakReference(this._value);

  T? get() => _value;
}

class View {
  // Implement View methods
}

class Menu {
  // Implement Menu methods
}

class Shelf {
  // Implement Shelf methods
}

class Member {
  // Implement Member methods
}

class BuildConfig {
  static String get VERSION_NAME => '1.0.0';
}

class LoginActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Activity'),
      ),
      body: Center(
        child: Text('Login Activity'),
      ),
    );
  }
}


// Dart code for Flutter framework

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class LoginActivity extends StatefulWidget {
  @override
  _LoginActivityState createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogout = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    isLogout = preferences.getString("token") != null;
    if (isLogout) {
      setState(() {
        usernameController.text = preferences.getString("username") ?? "N/A";
      });
    }
  }

  void _login() async {
    int salt = Random().nextInt(10000);
    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty) {
      _showToast('Username cannot be empty');
      return;
    }
    if (password.isEmpty) {
      _showToast('Password cannot be empty');
      return;
    }

    if (isLogout) {
      await MainActivity.member?.logout();
      await MainActivity.mainWeakReference?.get()?.refreshUserInfo();
      _showToast('Restart to apply changes');
      Navigator.of(context).pop();
      return;
    }

    var loginResponse = await MainActivity.member?.login(username, password, salt);
    if (loginResponse?.code == 200) {
      await MainActivity.mainWeakReference?.get()?.refreshUserInfo();
      Navigator.of(context).pop();
      return;
    }
    _showToast(loginResponse?.message ?? 'Login failed');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text(isLogout ? 'Logout' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}

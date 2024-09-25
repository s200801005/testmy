import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginActivity(),
    );
  }
}

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
    // Simulating the retrieval of preferences
    final preferences = {}; // Replace with actual preferences retrieval
    isLogout = preferences['token'] != null;
    if (isLogout) {
      usernameController.text = preferences['username'] ?? 'N/A';
    }
  }

  void login() async {
    final salt = Random().nextInt(10000);
    final username = usernameController.text;
    final password = passwordController.text;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username cannot be null')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password cannot be null')),
      );
      return;
    }

    if (isLogout) {
      // Simulating logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restart to apply changes')),
      );
      Navigator.of(context).pop();
      return;
    }

    // Simulating login process
    final loginResponse = await loginUser(username, password, salt);
    if (loginResponse.code == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loginResponse.message)),
    );
  }

  Future<LoginResponse> loginUser(String username, String password, int salt) async {
    // Simulate login API call
    // Replace with actual login logic
    return LoginResponse(200, 'Success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: login,
              child: Text(isLogout ? 'Logout' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginResponse {
  final int code;
  final String message;

  LoginResponse(this.code, this.message);
}

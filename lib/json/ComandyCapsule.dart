// Translated from Java to Dart
// Framework: Dart (Flutter or standalone Dart application)

class CommandCapsule {
  int code;
  String method;
  String url;
  Map<String, dynamic> headers; // Using dynamic to reflect Object in Java
  String data;

  CommandCapsule({
    required this.code,
    required this.method,
    required this.url,
    required this.headers,
    required this.data,
  });
}
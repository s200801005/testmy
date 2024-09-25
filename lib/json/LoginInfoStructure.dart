// This Dart code is part of a Flutter application.

class LoginInfoStructure extends ReturnBase {
  Results results;

  // Nested class Results
  class Results {
    String token;
    String userId; // Changed to camelCase for Dart conventions
    String username;
    String nickname;
    String avatar;
  }
}
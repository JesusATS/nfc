import 'package:flutter/foundation.dart';

class DebugUtils {
  static void log(String message) {
    if (kDebugMode) {
      print('[DEBUG] ${DateTime.now()} - $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('[ERROR] ${DateTime.now()} - $message');
    }
  }
}

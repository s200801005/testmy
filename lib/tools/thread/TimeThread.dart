// Dart code translated from Kotlin, assuming a Flutter framework for UI handling.

import 'dart:async';

class TimeThread {
  final Function(int) messageHandler;
  final int messageId;
  final Duration interval;
  bool canDo = false;

  TimeThread(this.messageHandler, this.messageId, {Duration? interval})
      : interval = interval ?? Duration(milliseconds: 3000);

  void start() {
    canDo = true;
    _run();
  }

  void stop() {
    canDo = false;
  }

  void _run() async {
    while (canDo) {
      try {
        messageHandler(messageId);
        await Future.delayed(interval);
      } catch (e) {
        print(e);
      }
    }
  }
}
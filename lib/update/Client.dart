// Dart implementation of Client class for socket communication
import 'dart:io';
import 'dart:async';

import 'ByteArrayQueue.dart';

class Client {
  final String ipAddress;
  final int portNumber;
  Socket? socket;
  late OutputStream outputStream;
  late InputStream inputStream;

  bool get isConnected => socket != null && inputStream != null && outputStream != null;

  Client(this.ipAddress, this.portNumber);

  /// Initializes the connection to the server
  Future<bool> initConnect([int retryCount = 0]) async {
    if (retryCount > 3) {
      print("connect server failed after $retryCount tries");
    } else {
      try {
        socket = await Socket.connect(ipAddress, portNumber);
        inputStream = socket!.asBroadcastStream();
        outputStream = socket!.outputStream;

        socket!.timeout(Duration(seconds: 10));
        if (isConnected) {
          print("connect server successful");
          return true;
        } else {
          print("connect server failed, now retrying...");
          return await initConnect(retryCount + 1);
        }
      } catch (e) {
        print(e);
      }
    }
    return false;
  }

  /// Sends a message to the server
  /// @param message The string to be sent to the server
  bool sendMessage(String? message) {
    return sendMessage(message?.codeUnits);
  }

  bool sendMessage(List<int>? message) {
    try {
      if (isConnected) {
        if (message != null) {
          outputStream.add(message);
          outputStream.flush();
          print("Send msg: ${String.fromCharCodes(message)}");
          return true;
        } else {
          print("The message to be sent is empty");
        }
        print("send message succeed");
      } else {
        print("send message failed: no connect");
      }
    } catch (e) {
      print("send message failed: crash");
      print(e);
    }
    return false;
  }

  int? read() {
    return inputStream.readByteSync();
  }

  final List<int> receiveBuffer = List.filled(65536, 0);
  final ByteArrayQueue buffer = ByteArrayQueue();

  Future<List<int>> receiveRawMessage(int totalSize, {bool setProgress = false}) async {
    if (totalSize == buffer.size) return buffer.popAll();
    else {
      try {
        if (isConnected) {
          print("开始接收服务端信息");
          while (totalSize > buffer.size) {
            final count = await inputStream.read(receiveBuffer);
            if (count > 0) {
              buffer.addAll(receiveBuffer.sublist(0, count));
              print("reply length: $count");
              if (setProgress && totalSize > 0) {
                progress?.notify((100 * buffer.size / totalSize).toInt());
              }
            } else {
              await Future.delayed(Duration(milliseconds: 10));
            }
          }
        } else {
          print("no connect to receive message");
        }
      } catch (e) {
        print("receive message failed");
        print(e);
      }
      return totalSize > 0 ? buffer.pop(totalSize) ?? [] : buffer.popAll();
    }
  }

  Future<String> receiveMessage(int totalSize) async {
    return String.fromCharCodes(await receiveRawMessage(totalSize));
  }

  /// Closes the connection
  Future<bool> closeConnect() async {
    try {
      await inputStream.close();
      await outputStream.close();
      await socket?.close();
      socket = null;
      inputStream = null;
      outputStream = null;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Progress? progress;
}

abstract class Progress {
  void notify(int progressPercentage);
}
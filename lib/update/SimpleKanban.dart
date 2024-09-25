// Dart code translation of Kotlin code for a SimpleKanban class
// This code is intended to be used with Flutter framework.

import 'dart:typed_data';
import 'dart:async';

import 'Client.dart';

class SimpleKanban {
  final Client client;
  final String password;

  SimpleKanban(this.client, this.password); //must run in thread

  Uint8List? get raw {
    int attempts = 3;
    Uint8List response;
    Uint8List firstReceived;

    do {
      response = Uint8List(0);
      if (client.initConnect()) {
        client.sendMessage('$password catquit');
        client.receiveRawMessage(33); // Welcome to simple kanban server.
        try {
          firstReceived = client.receiveRawMessage(4); // le
          int length = convertToInt(firstReceived);
          print('Msg len: $length');
          if (firstReceived.length > 4) {
            response += firstReceived.sublist(4);
          }
          response += client.receiveRawMessage(length - response.length, setProgress: true);
          break;
        } catch (e) {
          print(e);
        }
        client.closeConnect();
      }
    } while (attempts-- > 0);
    
    return response.isEmpty ? null : response;
  }

  int convertToInt(Uint8List buffer) {
    return (buffer[3] & 0xff) << 24 |
           (buffer[2] & 0xff) << 16 |
           (buffer[1] & 0xff) << 8 |
           (buffer[0] & 0xff);
  }

  Future<void> fetchRaw({Future<void> Function()? onLoadFailure, Future<void> Function(Uint8List data)? onLoadSuccess}) async {
    onLoadFailure ??= () async {
      print('Fetch dict failed');
    };
    onLoadSuccess ??= (data) async {
      print('Fetch dict success');
    };

    Uint8List? data = raw;
    if (data != null) {
      await onLoadSuccess(data);
    } else {
      await onLoadFailure();
    }
  }

  String operator [](int version) {
    if (client.initConnect()) {
      client.sendMessage('$password get$version quit');
      client.receiveRawMessage(36); // Welcome to simple kanban server. get
      String result;

      try {
        Uint8List firstReceived = client.receiveRawMessage(4);
        if (String.fromCharCodes(firstReceived) == 'null') return 'null';
        int length = convertToInt(firstReceived);
        print('Msg len: $length');
        Uint8List response = Uint8List(0);
        if (firstReceived.length > 4) {
          response += firstReceived.sublist(4);
        }
        response += client.receiveRawMessage(length - response.length);
        result = response.isNotEmpty ? String.fromCharCodes(response) : 'null';
      } catch (e) {
        print(e);
        return 'null';
      }
      client.closeConnect();
      return result;
    }
    return 'null';
  }
}
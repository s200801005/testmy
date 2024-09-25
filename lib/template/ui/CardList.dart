import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class CardList {
  final WeakReference<State<StatefulWidget>> fragment;
  final int cardWidth;
  final int cardHeight;
  final int cardPerRow;

  CardList(this.fragment, this.cardWidth, this.cardHeight, this.cardPerRow);

  State<StatefulWidget>? get that => fragment.target;
  List<Widget?> mRows = List.filled(20, null);
  int mIndex = 0;
  int mCount = 0;
  int cardLoadingWaits = 0;
  InitClickListeners? initClickListeners;
  bool exitCardList = false;

  void reset() {
    mRows = List.filled(20, null);
    mIndex = 0;
    mCount = 0;
    cardLoadingWaits = 0;
    exitCardList = false;
  }

  Future<void> manageRow(Future<void> Function(int index) whenFinish) async {
    if (exitCardList) return;
    if (mCount++ % cardPerRow == 0) {
      await inflateRow(++mIndex - 1, whenFinish);
    } else {
      await whenFinish(mIndex - 1);
    }
  }

  Future<void> inflateRow(int index, Future<void> Function(int index) whenFinish) async {
    if (exitCardList) return;
    final context = that?.context;
    if (context != null) {
      final row = Container(
        height: cardHeight + 16,
        child: Row(),
      );
      await Future.delayed(Duration.zero, () {
        if (exitCardList) return;
        that?.setState(() {
          // Add the row to the layout
        });
      });
      await recycleOneRow(row, index);
      await whenFinish(index);
    }
  }

  Future<void> recycleOneRow(Widget? v, int i) async {
    final relativeIndex = i % 20;
    if (mRows[relativeIndex] == null) {
      mRows[relativeIndex] = v;
    } else {
      final victim = mRows[relativeIndex];
      if (exitCardList) return;
      await Future.delayed(Duration.zero, () {
        that?.setState(() {
          // Remove the victim from the layout
        });
      });
      mRows[relativeIndex] = v;
    }
  }

  void postPauseLottie(LottieBuilder v) {
    v.controller?.stop();
    v.controller?.value = 0.0;
  }

  Future<void> addCard({
    required String name,
    String? append,
    String? head,
    String? path,
    String? chapterUUID,
    int? pn,
    bool isFinish = false,
    bool isNew = false,
  }) async {
    if (exitCardList) return;
    await manageRow((i) async {
      final context = that?.context;
      if (context != null) {
        final cardFrame = Container(
          child: Column(
            children: [
              Text(name),
              // Add other card details here
            ],
          ),
        );
        await addCard(cardFrame);
      }
    });
  }

  Future<void> addCard(Widget cardFrame) async {
    final context = that?.context;
    if (context != null) {
      final card = cardFrame; // Assuming cardFrame contains the card details
      final appendedName = name + (append ?? '');
      final head = head;
      final file = File('${(await getApplicationDocumentsDirectory()).path}/$name');
      if (exitCardList) return;
      await Future.delayed(Duration.zero, () {
        // Update the card frame with the details
      });
      if (!file.existsSync()) {
        if (head != null) {
          final waitMillis = cardLoadingWaits++ * 200;
          final imageUrl = Uri.parse(head);
          final response = await http.get(imageUrl);
          if (response.statusCode == 200) {
            final imageData = response.bodyBytes;
            await Future.delayed(Duration(milliseconds: waitMillis), () {
              if (exitCardList) return;
              // Update the image in the card frame
            });
          }
        } else {
          postPauseLottie(LottieBuilder.asset('assets/lottie.json'));
          // Set default image
        }
      } else {
        final img = File('${file.path}/head.jpg');
        postPauseLottie(LottieBuilder.asset('assets/lottie.json'));
        if (img.existsSync()) {
          await Future.delayed(Duration.zero, () {
            // Update the image in the card frame
          });
        } else {
          // Set default image
        }
      }
      if (isFinish) {
        // Show finish indicator
      }
      if (isNew) {
        // Show new indicator
      }
      initClickListeners?.prepareListeners(cardFrame, name, path, chapterUUID, pn);
      await Future.delayed(Duration.zero, () {
        if (!exitCardList) {
          // Add the card frame to the layout
        }
      });
    }
  }
}

abstract class InitClickListeners {
  void prepareListeners(Widget v, String name, String? path, String? chapterUUID, int? pn);
}


// Flutter framework
import 'package:flutter/material.dart';

class MangaCardView extends Card {
  MangaCardView(BuildContext context) : super(child: Container());
  MangaCardView.withAttributes(BuildContext context, {Key? key}) : super(key: key, child: Container());
  MangaCardView.withStyle(BuildContext context, {Key? key, required BoxDecoration decoration}) 
      : super(key: key, child: Container(decoration: decoration));

  String mangaName = "";
  String? additionalInfo;
  String? coverImageUrl;
  String? filePath;
  bool hasFinished = false;
  bool isNewRelease = false;
  int mangaIndex = 0;
  String? chapterIdentifier;
  int? totalPages;
}
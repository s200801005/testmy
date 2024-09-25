// Dart code translation of Kotlin code with the use of Flutter framework

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Volume {
  final String path;
  final String groupPathWord;
  final String Function(int) getString;
  final bool Function() isExit;
  late final String groupInfoApiUrlTemplate;
  late bool exit;

  Volume(this.path, this.groupPathWord, this.getString, this.isExit) {
    groupInfoApiUrlTemplate = getString(R.string.groupInfoApiUrl);
    exit = false;
  }

  List<PausableDownloader> downloaders = [];
  VolumeStructure? volume;

  Future<VolumeStructure?> updateChapters(int count) async {
    final int times = count ~/ 100;
    final int remain = count % 100;
    final List<VolumeStructure?> re = List.filled(remain != 0 ? (times + 1) : times, null);
    if (re.isEmpty) return null;

    debugPrint("MyV: $groupPathWord 卷共需加载 ${times == 0 ? 1 : times} 次");
    await download(re, 0, count);
    return volume;
  }

  String getApiUrl(int offset) {
    return groupInfoApiUrlTemplate.replaceAll("{host}", CMApi.myHostApiUrl)
                                   .replaceAll("{path}", path)
                                   .replaceAll("{groupPathWord}", groupPathWord)
                                   .replaceAll("{offset}", offset.toString());
  }

  Future<void> download(List<VolumeStructure?> re, int offset, int c) async {
    debugPrint("MyV: 下载偏移: $offset");
    final apiUrl = getApiUrl(offset);
    if (exit) return;

    final downloader = PausableDownloader(apiUrl, whenFinish: whenFinish(re, c - 100, offset + 100));
    downloaders.add(downloader);
    await downloader.run();
  }

  Function(ByteData) whenFinish(List<VolumeStructure?> re, int c, int offset) {
    return (ByteData result) async {
      try {
        final String jsonString = utf8.decode(result.buffer.asUint8List());
        final VolumeStructure r = VolumeStructure.fromJson(json.decode(jsonString));
        final int o = r.results.offset ~/ 100;
        re[o] = r;

        debugPrint("MyV: 获得 $groupPathWord 卷的 ${r.results.list.length} 章内容, 偏移 $o*100=${r.results.offset}, 共 ${re.length}");
        if (c > 0) {
          await download(re, offset, c);
          return;
        }
        if (re.any((element) => element == null)) { // have uncompleted items
          debugPrint("MyV: 下载未完成, 存在空卷");
          return;
        }
        if (re.isNotEmpty) { // safer check, likely
          re[0]?.let((it) {
            List<ChapterStructure> chapters = [];
            for (var v in re) {
              v?.results?.list?.forEach((chapter) {
                chapters.add(chapter);
              });
            }
            it.results?.list = chapters;
          });
          volume = re[0];
        }
      } catch (e) {
        print(e);
      }
    };
  }
}
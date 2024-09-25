import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:math';

class DownloadPool {
  final String folder;
  bool exit = false;
  bool wait = false;
  final Directory _saveFolder;

  // 回调函数类型
  typedef OnDownloadListener = void Function(String fileName, bool isSuccess, [String message]);
  typedef OnPageDownloadListener = void Function(String fileName, int downloaded, int total, bool isSuccess, [String message]);

  OnDownloadListener? onDownloadListener;
  OnPageDownloadListener? onPageDownloadListener;

  DownloadPool(this.folder, this._saveFolder) {
    _saveFolder = Directory(folder);
    if (!_saveFolder.existsSync()) _saveFolder.createSync(recursive: true);
  }

  void operator +=(Quest quest) {
    packZipFile(quest.fileName, quest.imgUrl);
    print('+= ${quest.fileName}, size: ${quest.imgUrl.length}');
  }

  void setOnDownloadListener(OnDownloadListener listener) {
    onDownloadListener = listener;
  }

  void setOnPageDownloadListener(OnPageDownloadListener listener) {
    onPageDownloadListener = listener;
  }

  void packZipFile(String fileName, List<String> imgUrls) {
    final tempFilePath = '${folder}/$fileName.tmp';
    final tempFile = File(tempFilePath);

    tempFile.parent.createSync(recursive: true);

    int start = 0;
    if (tempFile.existsSync()) {
      try {
        final zipFile = ZipFile(tempFilePath);
        start = zipFile.entries.length;
        zipFile.close();
        print('next download index: $start');
        if (start <= 0 || start >= imgUrls.length) {
          tempFile.deleteSync();
          tempFile.createSync(recursive: true);
          start = 0;
        }
      } catch (e) {
        print(e);
        tempFile.deleteSync();
        tempFile.createSync(recursive: true);
      }
    } else {
      tempFile.createSync(recursive: true);
    }

    ZipOutputStream zip;
    if (start > 0) {
      final fromZip = ZipInputStream(FileInputStream(tempFilePath));
      zip = ZipOutputStream(CheckedOutputStream(FileOutputStream(tempFilePath), CRC32()));
      zip.level = 9;
      fromZip.forEach((entry) async {
        await zip.putNextEntry(entry);
        await fromZip.transform(utf8.decoder).forEach((chunk) async {
          await zip.add(chunk.codeUnits);
        });
        await zip.closeEntry();
        await fromZip.closeEntry();
      });
    } else {
      zip = ZipOutputStream(CheckedOutputStream(FileOutputStream(tempFilePath), CRC32()));
      zip.level = 9;
    }

    var succeed = true;
    var lastIndex = -8;
    try {
      for (int index = start; index < imgUrls.length; index++) {
        while (wait && !exit) await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(1000)));
        if (exit) break;
        int tryTimes = 3;
        bool s = false;
        while (!s && tryTimes-- > 0) {
          final u = imgUrls[index];
          s = await _downloadAndWriteToFile(zip, u, index);
          if (exit) break;
          if (!s) await Future.delayed(Duration(seconds: 2));
          if (exit) break;
        }
        if (!s && tryTimes <= 0) {
          succeed = false;
          onPageDownloadListener?.call(fileName, index + 1, imgUrls.length, false, '超过最大重试次数');
          break;
        } else {
          onPageDownloadListener?.call(fileName, index + 1, imgUrls.length, true, '');
        }
        lastIndex = index;
      }
      await zip.close();
      if (succeed && lastIndex + 1 >= imgUrls.length) {
        final targetFile = File('$folder/$fileName');
        tempFile.renameSync(targetFile.path);
      }
      onPageDownloadListener?.call(fileName, 0, 0, true, '');
      onDownloadListener?.call(fileName, succeed, '');
    } catch (e) {
      print(e);
      onDownloadListener?.call(fileName, false, 'packZipFile');
    }
  }

  Future<bool> _downloadAndWriteToFile(ZipOutputStream zip, String url, int index) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final extension = url.contains('.webp') ? '.webp' : '.jpg';
      final entryName = '$index$extension';
      final entry = ZipEntry(entryName, DateTime.now());
      await zip.putNextEntry(entry);
      await zip.add(response.body.codeUnits);
      await zip.closeEntry();
      return true;
    }
    return false;
  }
}

class Quest {
  final String fileName;
  final List<String> imgUrl;

  Quest(this.fileName, this.imgUrl);
}

// 辅助类
class ZipFile {
  final String path;

  ZipFile(this.path);

  List<ZipEntry> get entries {
    final entries = <ZipEntry>[];
    final file = File(path);
    final inputStream = FileInputStream(file);
    final zipInputStream = ZipInputStream(inputStream);
    ZipEntry entry;
    while ((entry = zipInputStream.getNextEntry()) != null) {
      entries.add(entry);
    }
    zipInputStream.close();
    return entries;
  }

  void close() {}
}

class ZipEntry {
  final String name;
  final DateTime date;

  ZipEntry(this.name, this.date);
}

class ZipOutputStream extends StreamSink<List<int>> {
  final CheckedOutputStream _stream;
  int level = 9;

  ZipOutputStream(CheckedOutputStream stream) : _stream = stream;

  Future<void> putNextEntry(ZipEntry entry) async {
    // Implement putNextEntry logic
  }

  Future<void> add(List<int> data) async {
    _stream.add(data);
  }

  Future<void> closeEntry() async {
    // Implement closeEntry logic
  }

  @override
  Stream<List<int>> get onData => _stream.onData;

  @override
  void add(List<int> data) {
    _stream.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _stream.addError(error, stackTrace);
  }

  @override
  void close() {
    _stream.close();
  }
}

class CheckedOutputStream extends StreamSink<List<int>> {
  final FileOutputStream _stream;
  final CRC32 _crc32;

  CheckedOutputStream(FileOutputStream stream, CRC32 crc32) : _stream = stream, _crc32 = crc32;

  @override
  Stream<List<int>> get onData => _stream.onData;

  @override
  void add(List<int> data) {
    _crc32.update(data);
    _stream.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _stream.addError(error, stackTrace);
  }

  @override
  void close() {
    _stream.close();
  }
}

class FileOutputStream extends StreamSink<List<int>> {
  final File _file;
  final StreamController<List<int>> _controller = StreamController<List<int>>.broadcast();

  FileOutputStream(this._file) {
    _file.openWrite().listen(_controller.sink.add);
  }

  @override
  Stream<List<int>> get onData => _controller.stream;

  @override
  void add(List<int> data) {
    _controller.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _controller.addError(error, stackTrace);
  }

  @override
  void close() {
    _controller.close();
  }
}

class FileInputStream extends Stream<List<int>> {
  final File _file;

  FileInputStream(this._file) {
    _stream = _file.openRead();
  }

  Stream<List<int>> _stream;

  @override
  Stream<List<int>> get asStream => _stream;
}

class ZipInputStream extends Stream<ZipEntry> {
  final Stream<List<int>> _stream;
  ZipEntry? _currentEntry;

  ZipInputStream(this._stream);

  ZipEntry getNextEntry() {
    // Implement getNextEntry logic
    throw UnimplementedError();
  }

  @override
  Stream<ZipEntry> get asStream => _stream.map((data) => ZipEntry('', DateTime.now()));
}

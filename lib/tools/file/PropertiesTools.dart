// PropertiesTools.dart
// created by fumiama 20200724
import 'dart:io';
import 'dart:xml'; // Assuming a package for XML handling
import 'dart:async';

class PropertiesTools {
  final File propertiesFile;
  final Map<String, String> cache = {};

  PropertiesTools(this.propertiesFile) {
    if (!propertiesFile.existsSync()) {
      propertiesFile.parent.createSync(recursive: true);
      propertiesFile.parent.setWritableSync(true);
      _createNew(propertiesFile);
    } else if (propertiesFile.statSync().type == FileSystemEntityType.directory) {
      propertiesFile.parent.setWritableSync(true);
      propertiesFile.deleteSync();
      _createNew(propertiesFile);
    }
    propertiesFile.parent.setWritableSync(true);
    propertiesFile.parent.setReadableSync(true);
  }

  void _createNew(File file) {
    file.createSync();
    final outputStream = file.openWrite();
    _storeToXML(outputStream, 'store');
    outputStream.close();
    print('Generate new prop.');
  }

  PropertiesTools _loadFromXml(Stream<List<int>> inputStream) {
    // Placeholder for loading from XML implementation
    return this;
  }

  PropertiesTools _setProp(String? key, String? value) {
    // Placeholder for setting property implementation
    return this;
  }

  String operator [](String key) {
    if (cache.containsKey(key)) {
      return cache[key] ?? 'null';
    } else {
      final inputStream = propertiesFile.openRead();
      final result = _loadFromXml(inputStream).getProperty(key) ?? 'null';
      print('Read $key = $result');
      cache[key] = result;
      return result;
    }
  }

  void operator []=(String key, String value) {
    cache[key] = value;
    final outputStream = propertiesFile.openWrite();
    _setProp(key, value)._storeToXML(outputStream, 'store');
    outputStream.close();
    print('Set $key = $value');
  }

  String getProperty(String key) {
    // Placeholder for getting property implementation
    return '';
  }

  void _storeToXML(IOSink outputStream, String comment) {
    // Placeholder for storing to XML implementation
  }
}
// Translated from Kotlin to Dart
import 'dart:io';

class FileUtils {
  static void recursiveRemove(FileSystemEntity fileEntity) {
    if (fileEntity is Directory) {
      var contents = fileEntity.listSync();
      for (var item in contents) {
        if (item is Directory) {
          recursiveRemove(item);
        } else {
          item.deleteSync();
        }
      }
    }
    fileEntity.deleteSync();
  }

  static int sizeOf(FileSystemEntity fileEntity) {
    int totalSize = 0;
    if (fileEntity is Directory) {
      var contents = fileEntity.listSync();
      for (var item in contents) {
        totalSize += item is Directory ? sizeOf(item) : item.lengthSync();
      }
    }
    return totalSize;
  }
}
// Dart code for a FIFO queue implementation
// Fumiama 20210601
// byte_array_queue.dart

class ByteArrayQueue {
  List<int> elements = [];

  int get size => elements.length;

  void append(List<int> items) {
    elements.addAll(items);
  }

  List<int>? pop([int num = 1]) {
    if (num <= elements.length) {
      List<int> result = elements.sublist(0, num);
      elements = elements.sublist(num);
      return result;
    } else {
      return null;
    }
  }

  void clear() {
    elements = [];
  }

  List<int> popAll() {
    List<int> result = List.from(elements);
    clear();
    return result;
  }

  void operator +=(List<int> items) => append(items);
}
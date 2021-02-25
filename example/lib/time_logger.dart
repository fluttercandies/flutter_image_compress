class TimeLogger {
  String tag;

  TimeLogger([this.tag = ""]);

  int? start;

  void startRecoder() {
    start = DateTime.now().millisecondsSinceEpoch;
  }

  void logTime() {
    if (start == null) {
      print('The start is null, you must start recoder first.');
      return;
    }
    final diff = DateTime.now().millisecondsSinceEpoch - start!;
    if (tag != "") {
      print("$tag : $diff ms");
    } else {
      print("run time $diff ms");
    }
  }
}

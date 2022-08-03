class TimeLogger {
  TimeLogger([this.tag = '']);

  String tag;
  int? start;

  void startRecorder() {
    start = DateTime.now().millisecondsSinceEpoch;
  }

  void logTime() {
    if (start == null) {
      print('The start is null, you must start recorder first.');
      return;
    }
    final diff = DateTime.now().millisecondsSinceEpoch - start!;
    if (tag != '') {
      print('$tag : $diff ms');
    } else {
      print('run time $diff ms');
    }
  }
}

@JS('console')
library log;

import 'package:js/js.dart';

external void log(dynamic tag, dynamic msg);

bool showLog = false;

void jsLog(dynamic tag, dynamic msg) {
  if (showLog) {
    log(tag, msg);
  }
}

void dartLog(Object? msg) {
  if (showLog) {
    // ignore: avoid_print
    print(msg.toString());
  }
}

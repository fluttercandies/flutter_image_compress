library log;

import 'dart:developer' as dev;
import 'dart:js_interop';

@JS('console.log')
external void log(JSAny? tag, JSAny? msg);

bool showLog = false;

void jsLog(dynamic tag, dynamic msg) {
  if (showLog) {
    log(tag, msg);
  }
}

void dartLog(Object? msg) {
  if (showLog) {
    dev.log(msg.toString());
  }
}

import 'main/main_base.dart'
    if (dart.library.html) 'main/main_web.dart'
    if (dart.library.io) 'main/main_io.dart';

Future<void> main() async {
  await runMain();
}

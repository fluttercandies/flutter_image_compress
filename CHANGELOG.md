# CHANGELOG

## 0.5.2

Fix:

- [#49](https://github.com/OpenFlutter/flutter_image_compress/issues/49): A problem of reading Exif information.

## 0.5.1

Change `reportError` with flutter stable version.

**Breaking Change:**
The autoCorrectionAngle parameter causes a number of situations to behave differently than `0.4.0`. See readme for details.

## 0.5.0

(don't use)

**Breaking Change:**
Because `FlutterError.reportError` method's param `context` type changed.
So this library will add the constraints of flutter SDK so that users before 1.5.9 will not use version 0.5.0 incorrectly.

## 0.4.0

Some code has been added to ensure that parameters that do not pass in native do not trigger crash.

## 0.3.1

Fix:

- Android close file output stream.

## 0.3.0

Fix:

- optimize compress scale.

## 0.2.4

Updated Kotlin version

**Breaking change**. Migrate from the deprecated original Android Support
Library to AndroidX. This shouldn't result in any functional changes, but it
requires any Android apps using this plugin to [also
migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
using the original support library.

## 0.2.3

change iOS return type

## 0.2.2

add some dart doc

## 0.2.1

update readme

## 0.2.0

The version number is updated so that people who can use the higher version of gradle can use it. see pr #8

if android run error, you must update your kotlin'version to 1.2.71+

## 0.1.4

add optional params rotate

fix bug

update example

## 0.1.3

fix the ios `flutter.h` bug

## 0.1.1

update readme

## 0.1.0

first version

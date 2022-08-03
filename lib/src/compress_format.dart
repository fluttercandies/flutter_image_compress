enum CompressFormat {
  jpeg,
  png,

  /// - iOS: Supported from iOS11+.
  /// - Android: Supported from API 28+ which require hardware encoder supports,
  ///   Use [HeifWriter](https://developer.android.com/reference/androidx/heifwriter/HeifWriter.html)
  heic,

  /// Only supported on Android.
  webp,
}

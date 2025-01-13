enum CompressFormat {
  jpeg,
  png,
  webp,

  /// - iOS: Supported from iOS11+.
  /// - Android: Supported from API 28+ which require hardware encoder supports,
  ///   Use [HeifWriter](https://developer.android.com/reference/androidx/heifwriter/HeifWriter.html)
  heic,
}

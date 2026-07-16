class CompressError extends Error {
  CompressError(this.message, {this.code});

  final String message;

  /// Optional machine-readable failure code emitted by the native side.
  ///
  /// Stable values: `unsupported_format`, `decode_failed`, `encode_failed`,
  /// `io_failed`, `unknown`. Unknown codes are passed through verbatim so
  /// forward-compat callers can still branch on them without a plugin bump.
  final String? code;

  @override
  String toString() => code == null
      ? 'CompressError: $message'
      : 'CompressError($code): $message';
}

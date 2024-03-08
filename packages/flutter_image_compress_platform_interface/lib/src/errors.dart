class CompressError extends Error {
  CompressError(this.message);

  final String message;

  @override
  String toString() => 'CompressError: $message';
}

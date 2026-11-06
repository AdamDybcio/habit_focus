/// Thrown by local data sources when reading or writing storage fails.
class LocalStorageException implements Exception {
  /// Creates an exception with a developer-facing [message].
  const new(this.message);

  /// What went wrong. Never contains secrets.
  final String message;

  @override
  String toString() => 'LocalStorageException: $message';
}

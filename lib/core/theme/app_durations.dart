/// Animation durations. Motion explains cause and effect and stays short.
abstract final class AppDurations {
  /// 150 ms, micro-interactions such as state changes.
  static const Duration short = Duration(milliseconds: 150);

  /// 250 ms, default transitions.
  static const Duration medium = Duration(milliseconds: 250);

  /// 400 ms, large or emphasized transitions.
  static const Duration long = Duration(milliseconds: 400);
}

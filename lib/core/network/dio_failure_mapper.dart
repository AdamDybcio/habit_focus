import 'package:dio/dio.dart';
import 'package:habit_focus/core/error/app_failure.dart';

/// Maps a [DioException] to a typed [AppFailure].
///
/// The messages are developer-facing and never contain request or response
/// bodies.
AppFailure mapDioException(DioException exception) {
  final status = exception.response?.statusCode;
  if (status != null) {
    if (status == 401) {
      return const UnauthorizedFailure('Unauthorized');
    }
    if (status == 409) {
      return const ConflictFailure('Conflict');
    }
    if (status == 429) {
      return const TooManyRequestsFailure('Too many requests');
    }
    if (status == 400 || status == 422) {
      return ValidationFailure('Request rejected ($status)');
    }
    return NetworkFailure('Server answered with $status');
  }
  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => NetworkFailure(exception.type.name),
    _ => UnknownFailure(exception.type.name),
  };
}

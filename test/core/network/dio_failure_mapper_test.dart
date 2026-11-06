import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/network/dio_failure_mapper.dart';

DioException _exception({int? status, DioExceptionType? type}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type ?? DioExceptionType.badResponse,
    response: status == null
        ? null
        : Response<Object?>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('mapDioException', () {
    test('maps 401 to UnauthorizedFailure', () {
      expect(
        mapDioException(_exception(status: 401)),
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps 400 and 422 to ValidationFailure', () {
      expect(
        mapDioException(_exception(status: 400)),
        isA<ValidationFailure>(),
      );
      expect(
        mapDioException(_exception(status: 422)),
        isA<ValidationFailure>(),
      );
    });

    test('maps other statuses to NetworkFailure', () {
      expect(mapDioException(_exception(status: 500)), isA<NetworkFailure>());
      expect(mapDioException(_exception(status: 404)), isA<NetworkFailure>());
    });

    test('maps timeouts and connection errors to NetworkFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(
          mapDioException(_exception(type: type)),
          isA<NetworkFailure>(),
          reason: type.name,
        );
      }
    });

    test('maps anything else to UnknownFailure', () {
      expect(
        mapDioException(_exception(type: DioExceptionType.cancel)),
        isA<UnknownFailure>(),
      );
      expect(
        mapDioException(_exception(type: DioExceptionType.unknown)),
        isA<UnknownFailure>(),
      );
    });
  });
}

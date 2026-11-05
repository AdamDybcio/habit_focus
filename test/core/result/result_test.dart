import 'package:flutter_test/flutter_test.dart';
import 'package:habit_focus/core/error/app_failure.dart';
import 'package:habit_focus/core/result/result.dart';

void main() {
  group('Result', () {
    test('Success exposes its value', () {
      const result = Success<int>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, 42);
    });

    test('Failure exposes its typed error', () {
      const result = Failure<int>(NetworkFailure('offline'));

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, const NetworkFailure('offline'));
    });

    test('when calls the success branch for Success', () {
      const Result<int> result = Success(2);

      final text = result.when(
        success: (value) => 'value $value',
        failure: (error) => error.message,
      );

      expect(text, 'value 2');
    });

    test('when calls the failure branch for Failure', () {
      const Result<int> result = Failure(StorageFailure('disk full'));

      final text = result.when(
        success: (value) => 'value $value',
        failure: (error) => error.message,
      );

      expect(text, 'disk full');
    });

    test('results with equal content are equal', () {
      expect(const Success<int>(1), const Success<int>(1));
      expect(
        const Failure<int>(NetworkFailure('x')),
        const Failure<int>(NetworkFailure('x')),
      );
    });

    test('results with different content are not equal', () {
      expect(const Success<int>(1), isNot(const Success<int>(2)));
      expect(
        const Failure<int>(NetworkFailure('x')),
        isNot(const Failure<int>(StorageFailure('x'))),
      );
    });
  });
}

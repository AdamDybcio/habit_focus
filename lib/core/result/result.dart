import 'package:equatable/equatable.dart';
import 'package:habit_focus/core/error/app_failure.dart';

/// Outcome of an operation that can fail without throwing.
sealed class Result<T> extends Equatable {
  /// Creates a result.
  const new();

  /// Whether this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Collapses the result into a single value.
  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure error) failure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Failure<T>(:final error) => failure(error),
    };
  }
}

/// A successful [Result] carrying [value].
final class Success<T> extends Result<T> {
  /// Creates a successful result.
  const new(this.value);

  /// The produced value.
  final T value;

  @override
  List<Object?> get props => [value];
}

/// A failed [Result] carrying a typed [error].
final class Failure<T> extends Result<T> {
  /// Creates a failed result.
  const new(this.error);

  /// What went wrong.
  final AppFailure error;

  @override
  List<Object?> get props => [error];
}

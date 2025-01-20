// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../exception_state/exception_state.dart';
import '../utils/utils.dart';

// coverage:ignore-start
/// An sealed base ResultState class
/// to [TModel] represents the different states of result.
@Deprecated('Use class Result() instead.')
sealed class ResultState<TModel> extends CustomEquatable {
  const ResultState();
}

/// Success status with a generic value [TModel].
@Deprecated('Use class OK() instead.')
final class SuccessState<TModel> extends ResultState<TModel> {
  const SuccessState(this.data);

  final TModel data;

  @override
  Map<String, Object?> get namedProps => {'data': data};
}

/// Error status with a specific type of exception.
@Deprecated('Use class Error() instead.')
final class FailureState<TModel> extends ResultState<TModel> {
  const FailureState(this.exception);

  final ExceptionState<TModel> exception;

  @override
  Map<String, Object?> get namedProps => {'exception': exception};
}
// coverage:ignore-end

/// Utility class that simplifies handling errors.
///
/// Inspired by the [Result] class from the official Dart language documentation https://docs.flutter.dev/app-architecture/design-patterns/result#putting-it-all-together.
///
/// Use this class to return a `Result` from a function, indicating success or failure.
///
/// A `Result` object can be either an `Ok` with a value of type `T`, or an `Error` with an `Exception`.
///
/// Use `Result.ok(value)` to create a successful result with a value of type `T`.
/// Use `Result.error(exception)` to create an error result with an `Exception`.
///
/// Example:
///
/// /// A function that returns a `Result` object.
/// ```dart
/// Result<int> getResult() {
///  try {
///   // Some code that might throw an exception.
///  return Result.ok(42);
/// } catch (e) {
///  return Result.error(Exception(e));
/// }
/// ```
sealed class Result<T> extends CustomEquatable {
  const Result();

  /// Creates an instance of Result containing a value.
  factory Result.ok(final T value) => Ok(value);

  /// Create an instance of Result containing an error.
  factory Result.error(final Exception error) => Error(error);
}

/// Subclass of Result for values.
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  /// Returned value in result.
  final T value;

  @override
  Map<String, Object?> get namedProps => {'value': value};
}

/// Subclass of Result for errors.
final class Error<T> extends Result<T> {
  const Error(this.error);

  /// Returned error in result.
  final Exception error;

  @override
  Map<String, Object?> get namedProps => {'error': error};
}

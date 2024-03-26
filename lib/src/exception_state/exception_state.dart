// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'dart:developer';

import 'package:http_exception/http_exception.dart';

import '../utils/utils.dart';

/// [ExceptionState] sealed class represents a generic state for handling
/// various exceptions.
///
/// It includes optional fields for different exception types.
sealed class ExceptionState<TModel> extends CustomEquatable
    implements Exception {
  const ExceptionState({
    required this.message,
    required this.stackTrace,
  });

  /// A message describing the format error.
  final String message;
  final StackTrace stackTrace;
}

/// [DataClientExceptionState] captures exceptions related to client-side
/// issues.
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataClientExceptionState<TModel> extends ExceptionState<TModel> {
  DataClientExceptionState({
    required final String message,
    required final StackTrace stackTrace,
  }) : super(message: message, stackTrace: stackTrace) {
    log(
      'Client exception captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataClientExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps =>
      <String, Object?>{'clientException': message};
}

/// [DataParseExceptionState] handles exceptions related to parsing issues
/// (e.g., JSON parsing).
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataParseExceptionState<TModel> extends ExceptionState<TModel> {
  DataParseExceptionState({
    required final StackTrace stackTrace,
    final String message = 'Error parsing data.',
  }) : super(message: message, stackTrace: stackTrace) {
    log(
      'Unable to parse the json:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataParseExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'parseException': message};
}

/// [DataHttpExceptionState] is used for handling HTTP-related exceptions.
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataHttpExceptionState<TModel> extends ExceptionState<TModel> {
  DataHttpExceptionState({
    required this.httpException,
    required final StackTrace stackTrace,
    final String? message,
  }) : super(
          message: message ?? '',
          stackTrace: stackTrace,
        ) {
    log(
      'A $httpException, captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataHttpExceptionState',
    );
  }

  final HttpException httpException;

  @override
  Map<String, Object?> get namedProps =>
      {'httpException': httpException, 'message': message};
}

/// [DataNetworkExceptionState] is for handling network-related exceptions
/// (e.g., no internet connection).
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataNetworkExceptionState<TModel> extends ExceptionState<TModel> {
  DataNetworkExceptionState({
    required final StackTrace stackTrace,
    final String message = 'A network error occurred.',
  }) : super(message: message, stackTrace: stackTrace) {
    log(
      'Network exception captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataNetworkExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'networkException': message};
}

/// [DataCacheExceptionState] is used for handling exceptions related to data
/// caching operations.
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataCacheExceptionState<TModel> extends ExceptionState<TModel> {
  DataCacheExceptionState({
    required final StackTrace stackTrace,
    final String message = 'A cache error occurred.',
  }) : super(message: message, stackTrace: stackTrace) {
    log(
      'Cache exception captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataCacheExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'cacheException': message};
}

/// [DataInvalidInputExceptionState] is used for handling exceptions related to
/// invalid input data.
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataInvalidInputExceptionState<TModel> extends ExceptionState<TModel> {
  DataInvalidInputExceptionState({
    required final StackTrace stackTrace,
    final String message = 'Invalid input provided.',
  }) : super(message: message, stackTrace: stackTrace) {
    log(
      'Invalid Input exception captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataInvalidInputExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'invalidInputException': message};
}

/// [DataUnknownExceptionState] is used for handling exceptions related to
/// Unknown error data.
///
/// This exception class extends [ExceptionState], providing a generic type
/// [TModel] to allow encapsulating additional information or data related to
/// the exception.
class DataUnknownExceptionState<TModel> extends ExceptionState<TModel> {
  DataUnknownExceptionState({
    required final String message,
    required final StackTrace stackTrace,
  }) : super(message: message, stackTrace: stackTrace) {
    log(
      'Unknown exception captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataUnknownExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'unknownException': message};
}

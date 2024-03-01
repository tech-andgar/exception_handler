// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'dart:developer';

import 'package:http_exception/http_exception.dart';

import '../utils/utils.dart';

/// Represents errors related to network communication.
class NetworkException implements Exception {
  const NetworkException({this.message = 'A network error occurred.'});

  final String message;
}

/// Represents errors related to data caching operations.
class CacheException implements Exception {
  const CacheException({this.message = 'A cache error occurred.'});

  final String message;
}

/// Represents errors due to invalid user input.
class InvalidInputException implements Exception {
  const InvalidInputException({this.message = 'Invalid input provided.'});

  final String message;
}

/// Represents errors when the database is not found.
class DatabaseNotFoundException implements Exception {
  const DatabaseNotFoundException({this.message = 'Database not found.'});

  final String message;
}

/// Represents errors due to provision of invalid data.
class InvalidDataException implements Exception {
  const InvalidDataException({this.message = 'Invalid data provided.'});

  final String message;
}

/// Represents errors encountered during parsing of data.
class DataParsingException implements Exception {
  const DataParsingException({this.message = 'Error parsing data.'});

  final String message;
}

/// Represents errors encountered while saving data.
class DataPersistenceException implements Exception {
  const DataPersistenceException({this.message = 'Error saving data.'});

  final String message;
}

/// Represents timeouts when waiting for a response.
class ReceiveTimeoutException implements Exception {
  const ReceiveTimeoutException({
    this.message = 'The connection has timed out.',
  });

  final String message;
}

/// Represents the absence of an internet connection.
class NoInternetConnectionException implements Exception {
  const NoInternetConnectionException({
    this.message = 'No internet connection detected.',
  });

  final String message;
}

/// Represents timeouts when sending data.
class SendTimeoutException implements Exception {
  const SendTimeoutException({
    this.message = 'The connection timed out while sending data.',
  });

  final String message;
}

/// Represents an operation cancellation.
class CancelException implements Exception {
  const CancelException({this.message = 'The operation was cancelled.'});

  final String message;
}

/// Represents the failure of user authentication.
class AuthenticationFailedException implements Exception {
  const AuthenticationFailedException({
    this.message = 'Authentication failed.',
  });

  final String message;
}

/// Represents an error due to an expired token.
class TokenExpiredException implements Exception {
  const TokenExpiredException({this.message = 'Token has expired.'});

  final String message;
}

/// Represents an error due to denied access.
class AccessDeniedException implements Exception {
  const AccessDeniedException({this.message = 'Access denied.'});

  final String message;
}

/// Represents errors related to configuration issues.
class ConfigurationException implements Exception {
  const ConfigurationException({
    this.message = 'Configuration error occurred.',
  });

  final String message;
}

/// Represents errors when a required dependency is not found.
class DependencyNotFoundException implements Exception {
  const DependencyNotFoundException({
    this.message = 'Required dependency was not found.',
  });

  final String message;
}

/// Represents errors when a requested feature is not supported.
class FeatureNotSupportedException implements Exception {
  const FeatureNotSupportedException({
    this.message = 'This feature is not supported.',
  });

  final String message;
}

/// Represents errors of an unknown nature.
class UnknownErrorException implements Exception {
  const UnknownErrorException({this.message = 'An unknown error occurred.'});

  final String message;
}

/// [ExceptionState] sealed class represents a generic state for handling
/// various exceptions.
///
/// It includes optional fields for different exception types.
sealed class ExceptionState<TModel> extends CustomEquatable
    implements Exception {
  /// A message describing the format error.
  final String message;
  final StackTrace stackTrace;

  const ExceptionState({
    required this.message,
    required this.stackTrace,
  });
}

/// [DataClientExceptionState] captures exceptions related to client-side
/// issues.
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataClientExceptionState<TModel> extends ExceptionState<TModel> {
  DataClientExceptionState(String message, StackTrace stackTrace)
      : super(message: message, stackTrace: stackTrace) {
    log(
      'Client exception captured:',
      error: message,
      stackTrace: stackTrace,
      name: 'DataClientExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'clientException': message};
}

/// [DataParseExceptionState] handles exceptions related to parsing issues
/// (e.g., JSON parsing).
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataParseExceptionState<TModel> extends ExceptionState<TModel> {
  DataParseExceptionState(String message, StackTrace stackTrace)
      : super(message: message, stackTrace: stackTrace) {
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
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataHttpExceptionState<TModel> extends ExceptionState<TModel> {
  DataHttpExceptionState({
    required this.httpException,
    required StackTrace stackTrace,
    Exception? exception,
  }) : super(message: httpException.toString(), stackTrace: stackTrace) {
    log(
      'A $httpException, captured:',
      error: exception.toString(),
      stackTrace: stackTrace,
      name: 'DataHttpExceptionState',
    );
  }

  final HttpException httpException;

  @override
  Map<String, Object?> get namedProps => {'httpException': httpException};
}

/// [DataNetworkExceptionState] is for handling network-related exceptions
/// (e.g., no internet connection).
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataNetworkExceptionState<TModel> extends ExceptionState<TModel> {
  DataNetworkExceptionState(String message, StackTrace stackTrace)
      : super(message: message, stackTrace: stackTrace) {
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
/// caching.
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataCacheExceptionState<TModel> extends ExceptionState<TModel> {
  DataCacheExceptionState(String message, StackTrace stackTrace)
      : super(message: message, stackTrace: stackTrace) {
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
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataInvalidInputExceptionState<TModel> extends ExceptionState<TModel> {
  DataInvalidInputExceptionState(
    String message,
    StackTrace stackTrace,
  ) : super(message: message, stackTrace: stackTrace) {
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

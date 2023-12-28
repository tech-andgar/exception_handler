import 'dart:developer';

import '../utils/utils.dart';

// Enums defining different types of exceptions for clear and specific error
// handling.

enum NetworkException {
  noInternetConnection,
  timeOutException,
  unknown,
}

enum HttpException {
  unauthorized,
  internalServerError,
  unknown,
  unknownRedirect,
  unknownClient,
  unknownServer,
}

/// ExceptionState class represents a generic state for handling various
/// exceptions.
///
/// It includes optional fields for different exception types.
sealed class ExceptionState<T> extends CustomEquatable {
  final Exception? clientException;
  final Exception? parseException;
  final HttpException? httpException;
  final NetworkException? networkException;
  final StackTrace stackTrace;

  const ExceptionState({
    this.clientException,
    this.parseException,
    this.httpException,
    this.networkException,
    required this.stackTrace,
  });
}

/// DataClientException captures exceptions related to client-side issues.
class DataClientException<T> extends ExceptionState<T> {
  DataClientException(Exception exception, StackTrace stackTrace)
      : super(clientException: exception, stackTrace: stackTrace) {
    log(
      'DataClientException: client exception captured',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataClientException',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'clientException': clientException};
}

/// DataParseException handles exceptions related to parsing issues
/// (e.g., JSON parsing).
class DataParseException<T> extends ExceptionState<T> {
  DataParseException(Exception exception, StackTrace stackTrace)
      : super(parseException: exception, stackTrace: stackTrace) {
    log(
      'DataParseException: Unable to parse the json',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataParseException',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'parseException': parseException};
}

/// DataHttpException is used for handling HTTP-related exceptions.
class DataHttpException<T> extends ExceptionState<T> {
  DataHttpException(HttpException exception, StackTrace stackTrace)
      : super(httpException: exception, stackTrace: stackTrace) {
    log(
      'DataHttpException: a Http exception captured',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataHttpException',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'httpException': httpException};
}

/// DataNetworkException is for handling network-related exceptions
/// (e.g., no internet connection).
class DataNetworkException<T> extends ExceptionState<T> {
  DataNetworkException(NetworkException exception, StackTrace stackTrace)
      : super(networkException: exception, stackTrace: stackTrace) {
    log(
      'DataNetworkException: network exception captured',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataNetworkException',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'networkException': networkException};
}

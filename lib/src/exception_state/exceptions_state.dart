import 'dart:developer';

import '../utils/utils.dart';

// Enums defining different types of exceptions for clear and specific error
// handling.

enum NetworkException {
  noInternetConnection,
  timeOutException,
  unknown,
}

enum CacheException {
  unknown,
}

enum InvalidInputException {
  unknown,
}

enum HttpException {
  // 1xx - Informative Responses
  continue_,
  switchingProtocols,
  processing,
  earlyHints,
  // 2xx - Successful Responses
  oK,
  created,
  accepted,
  nonAuthoritativeInformation,
  noContent,
  resetContent,
  partialContent,
  multiStatus,
  alreadyReported,
  iMUsed,
  // 3xx - Redirections
  movedPermanently,
  found,
  notModified,
  useProxy,
  switchProxy,
  temporaryRedirect,
  unknownRedirect,
  // 4xx - Client Errors
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  methodNotAllowed,
  notAcceptable,
  proxyAuthenticationRequired,
  requestTimeout,
  conflict,
  gone,
  lengthRequired,
  preconditionFailed,
  payloadTooLarge,
  uRITooLong,
  unsupportedMediaType,
  rangeNotSatisfiable,
  expectationFailed,
  imATeapot,
  misdirectedRequest,
  unprocessableEntity,
  locked,
  failedDependency,
  upgradeRequired,
  preconditionRequired,
  tooManyRequests,
  requestHeaderFieldsTooLarge,
  unavailableForLegalReasons,
  unknownClient,
  // 5xx - Server Errors
  internalServerError,
  notImplemented,
  serviceUnavailable,
  gatewayTimeout,
  badGateway,
  hTTPVersionNotSupported,
  variantAlsoNegotiates,
  insufficientStorage,
  loopDetected,
  notExtended,
  networkAuthenticationRequired,
  bandwidthLimitExceeded,
  unknownError,
  webServerIsDown,
  connectionTimedOut,
  originIsUnreachable,
  aTimeoutOccurred,
  sSLHandshakeFailed,
  invalidSSLCertificate,
  unknownServer,
  unknown,
}

/// [ExceptionState] sealed class represents a generic state for handling
/// various exceptions.
///
/// It includes optional fields for different exception types.
sealed class ExceptionState<T> extends CustomEquatable {
  final CacheException? cacheException;
  final Exception? clientException;
  final InvalidInputException? invalidInputException;
  final Exception? parseException;
  final HttpException? httpException;
  final NetworkException? networkException;
  final StackTrace stackTrace;

  const ExceptionState({
    this.cacheException,
    this.clientException,
    this.invalidInputException,
    this.parseException,
    this.httpException,
    this.networkException,
    required this.stackTrace,
  });
}

/// [DataClientExceptionState] captures exceptions related to client-side
/// issues.
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataClientExceptionState<T> extends ExceptionState<T> {
  DataClientExceptionState(Exception exception, StackTrace stackTrace)
      : super(clientException: exception, stackTrace: stackTrace) {
    log(
      'Client exception captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataClientExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'clientException': clientException};
}

/// [DataParseExceptionState] handles exceptions related to parsing issues
/// (e.g., JSON parsing).
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataParseExceptionState<T> extends ExceptionState<T> {
  DataParseExceptionState(Exception exception, StackTrace stackTrace)
      : super(parseException: exception, stackTrace: stackTrace) {
    log(
      'Unable to parse the json:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataParseExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'parseException': parseException};
}

/// [DataHttpExceptionState] is used for handling HTTP-related exceptions.
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataHttpExceptionState<T> extends ExceptionState<T> {
  DataHttpExceptionState({
    required HttpException httpException,
    required StackTrace stackTrace,
    Exception? exception,
    this.statusCode,
  }) : super(httpException: httpException, stackTrace: stackTrace) {
    log(
      'A $httpException${statusCode != null ? ' $statusCode' : null} captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataHttpExceptionState',
    );
  }

  final int? statusCode;

  @override
  Map<String, Object?> get namedProps => {
        'httpException': httpException,
        'statusCode': statusCode,
      };
}

/// [DataNetworkExceptionState] is for handling network-related exceptions
/// (e.g., no internet connection).
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataNetworkExceptionState<T> extends ExceptionState<T> {
  DataNetworkExceptionState(NetworkException exception, StackTrace stackTrace)
      : super(networkException: exception, stackTrace: stackTrace) {
    log(
      'Network exception captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataNetworkExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'networkException': networkException};
}

/// [DataCacheExceptionState] is used for handling exceptions related to data
/// caching.
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataCacheExceptionState<T> extends ExceptionState<T> {
  DataCacheExceptionState(CacheException exception, StackTrace stackTrace)
      : super(cacheException: exception, stackTrace: stackTrace) {
    log(
      'Cache exception captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataCacheExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'cacheException': cacheException};
}

/// [DataInvalidInputExceptionState] is used for handling exceptions related to
/// invalid input data.
///
/// This exception class extends [ExceptionState], providing a generic type [T]
/// to allow encapsulating additional information or data related to
/// the exception.
class DataInvalidInputExceptionState<T> extends ExceptionState<T> {
  DataInvalidInputExceptionState(
    InvalidInputException exception,
    StackTrace stackTrace,
  ) : super(invalidInputException: exception, stackTrace: stackTrace) {
    log(
      'Invalid Input exception captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataInvalidInputExceptionState',
    );
  }

  @override
  Map<String, Object?> get namedProps =>
      {'invalidInputException': invalidInputException};
}

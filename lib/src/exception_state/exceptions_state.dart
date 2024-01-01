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
      'Client exception captured:',
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
      'Unable to parse the json:',
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
  DataHttpException({
    required HttpException httpException,
    required StackTrace stackTrace,
    Exception? exception,
    this.statusCode,
  }) : super(httpException: httpException, stackTrace: stackTrace) {
    log(
      'A $httpException${statusCode != null ? ' $statusCode' : null} captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataHttpException',
    );
  }
  final int? statusCode;

  @override
  Map<String, Object?> get namedProps => {
        'httpException': httpException,
        'statusCode': statusCode,
      };
}

/// DataNetworkException is for handling network-related exceptions
/// (e.g., no internet connection).
class DataNetworkException<T> extends ExceptionState<T> {
  DataNetworkException(NetworkException exception, StackTrace stackTrace)
      : super(networkException: exception, stackTrace: stackTrace) {
    log(
      'Network exception captured:',
      error: exception,
      stackTrace: stackTrace,
      name: 'DataNetworkException',
    );
  }

  @override
  Map<String, Object?> get namedProps => {'networkException': networkException};
}

class ServerException implements Exception {}

class CacheException implements Exception {}

class InvalidInputException implements Exception {}

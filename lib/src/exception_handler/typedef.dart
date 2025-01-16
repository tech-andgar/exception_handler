// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../src.dart';

typedef ApiCall<R, T> = Future<R> Function();
typedef ParseFunction<T> = T Function(Object?);

class ApiHandler<R, T> {
  ApiHandler({required this.apiCall, required this.parserModel});

  final ApiCall<R, T> apiCall;
  final ParseFunction<T> parserModel;
}

class ResponseParser<R, T> extends CustomEquatable {
  const ResponseParser({
    required this.response,
    required this.parserModel,
    this.exception,
    this.stackTrace,
  });

  final ParseFunction<T> parserModel;
  final R response;
  final Exception? exception;
  final StackTrace? stackTrace;

  @override
  Map<String, Object?> get namedProps => {
        'parserModel': parserModel,
        'response': response,
        'exception': exception,
        'stackTrace': stackTrace,
      };
}

class HandleHttpParseResponse<R, T> {
  HandleHttpParseResponse({
    this.handleHttp1xxParseResponse,
    // TODO(andgar2010): investigation bug.
    //    this.handleHttp2xxParseResponse,
    this.handleHttp3xxParseResponse,
    this.handleHttp4xxParseResponse,
    this.handleHttp5xxParseResponse,
    this.handleHttpUnknownParseResponse,
  });

  final Future<Result<T>> Function<R, T>(
    int statusCode,
    ResponseParser<R, T>,
  )? handleHttp1xxParseResponse;

  // TODO(andgar2010): investigation bug.
  // final Future<Result<T>> Function<T>(
  //   ResponseParser,
  // )? handleHttp2xxParseResponse;

  final Future<Result<T>> Function<R, T>(
    int statusCode,
    ResponseParser<R, T>,
  )? handleHttp3xxParseResponse;

  final Future<Result<T>> Function<R, T>(
    int statusCode,
    ResponseParser<R, T>,
  )? handleHttp4xxParseResponse;

  final Future<Result<T>> Function<R, T>(
    int statusCode,
    ResponseParser<R, T>,
  )? handleHttp5xxParseResponse;

  final Future<Result<T>> Function<R, T>(
    int statusCode,
    ResponseParser<R, T>,
  )? handleHttpUnknownParseResponse;
}

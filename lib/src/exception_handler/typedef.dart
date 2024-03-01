// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../src.dart';

typedef ApiCall<R, TModel> = Future<R> Function();
typedef ParseFunction<TModel> = TModel Function(Object?);

class ApiHandler<R, TModel> {
  ApiHandler({required this.apiCall, required this.parserModel});

  final ApiCall<R, TModel> apiCall;
  final ParseFunction<TModel> parserModel;
}

class ResponseParser<R, TModel> extends CustomEquatable {
  const ResponseParser({
    required this.response,
    required this.parserModel,
    this.exception,
    this.stackTrace,
  });

  final ParseFunction<TModel> parserModel;
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

class HandleHttpParseResponse<R, TModel> {
  HandleHttpParseResponse({
    this.handleHttp1xxParseResponse,
    this.handleHttp2xxParseResponse,
    this.handleHttp3xxParseResponse,
    this.handleHttp4xxParseResponse,
    this.handleHttp5xxParseResponse,
    this.handleHttpUnknownParseResponse,
  });

  final Future<ResultState<TModel>> Function<R, TModel>(
    int statusCode,
    ResponseParser<R, TModel>,
  )? handleHttp1xxParseResponse;

  final Future<ResultState<TModel>> Function<R, TModel>(
    int statusCode,
    ResponseParser<R, TModel>,
  )? handleHttp2xxParseResponse;

  final Future<ResultState<TModel>> Function<R, TModel>(
    int statusCode,
    ResponseParser<R, TModel>,
  )? handleHttp3xxParseResponse;

  final Future<ResultState<TModel>> Function<R, TModel>(
    int statusCode,
    ResponseParser<R, TModel>,
  )? handleHttp4xxParseResponse;

  final Future<ResultState<TModel>> Function<R, TModel>(
    int statusCode,
    ResponseParser<R, TModel>,
  )? handleHttp5xxParseResponse;

  final Future<ResultState<TModel>> Function<R, TModel>(
    int statusCode,
    ResponseParser<R, TModel>,
  )? handleHttpUnknownParseResponse;
}

// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../utils/utils.dart';

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

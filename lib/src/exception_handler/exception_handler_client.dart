// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../../exception_handler.dart';

export 'dio/dio.dart';
export 'typedef.dart';

abstract class ClientExceptionHandler {
  // coverage:ignore-start
  ClientExceptionHandler._();
  // coverage:ignore-end

  /// Method [callApi] is a generic method to handle API calls and return a tuple of
  /// ExceptionState and parsed data.
  ///
  Future<ResultState<TModel>> callApi_<R, TModel>(
    ApiHandler<R, TModel> apiHandler, {
    HandleHttpParseResponse<R, TModel>? handleHttpParseResponse,
  });

  /// Method [callApi] is a generic method to handle API calls and return a tuple of
  /// ExceptionState and parsed data.
  ///
  static Future<ResultState<TModel>> callApi<R, TModel>(
    ApiHandler<R, TModel> apiHandler, {
    HandleHttpParseResponse<R, TModel>? handleHttpParseResponse,
  }) async {
    throw UnimplementedError();
  }
}

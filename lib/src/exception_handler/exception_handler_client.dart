// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import '../../exception_handler.dart';

export 'dio/dio.dart';
export 'typedef.dart';

abstract class ClientExceptionHandler {
  /// callApi is a generic method to handle API calls and return a tuple of
  /// ExceptionState and parsed data.
  Future<ResultState<TModel>> callApi<R, TModel>(
    ApiHandler<R, TModel> apiHandler,
  );
}

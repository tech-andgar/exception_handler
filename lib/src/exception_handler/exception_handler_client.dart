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

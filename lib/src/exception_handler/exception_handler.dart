import '../../exception_handler.dart';

export 'exception_handler_dio.dart';
export 'typedef.dart';

abstract class ExceptionHandler {
  /// callApi is a generic method to handle API calls and return a tuple of
  /// ExceptionState and parsed data.
  Future<TaskResult<T>> callApi<R, T>(ApiHandler<R, T> apiHandler);
}

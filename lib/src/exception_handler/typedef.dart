import '../utils/utils.dart';

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

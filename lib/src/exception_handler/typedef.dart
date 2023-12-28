import 'package:dio/dio.dart';

import '../utils/utils.dart';

typedef ApiCall<T> = Future<Response<dynamic>> Function();
typedef ParseFunction<T> = T Function(Object?);

class ApiHandler<T> {
  ApiHandler({required this.call, required this.parserModel});

  final ApiCall<T> call;
  final ParseFunction<T> parserModel;
}

class ResponseParser<T> extends CustomEquatable {
  const ResponseParser({
    required this.response,
    required this.parserModel,
    this.exception,
    this.stackTrace,
  });

  final ParseFunction<T> parserModel;
  final Response<dynamic> response;
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

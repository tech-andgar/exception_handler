import 'package:dio/dio.dart';

typedef ApiCall<T> = Future<Response<dynamic>> Function();
typedef ParseFunction<T> = T Function(dynamic);

class ApiHandler<T> {
  ApiHandler({required this.call, required this.parserModel});

  final ApiCall<T> call;
  final ParseFunction<T> parserModel;
}

class ResponseParser<T> {
  ResponseParser({required this.response, required this.parserModel});

  final ParseFunction<T> parserModel;
  final Response<dynamic> response;
}

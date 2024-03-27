import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'ApiHandler',
    () {
      test(
        'should correctly pass call and parserModel to properties',
        () async {
          Future<Response<String>> mockApiCall() async => Response(
                data: 'test data',
                statusCode: 200,
                requestOptions: RequestOptions(),
              );
          String mockParserModel(final Object? data) => 'Parsed $data';

          final handler = ApiHandler<Response<Object?>, String>(
            apiCall: mockApiCall,
            parserModel: mockParserModel,
          );

          expect(await handler.apiCall(), isA<Response<Object?>>());
          expect(handler.parserModel('data'), equals('Parsed data'));
        },
      );
    },
  );
  group(
    'ResponseParser',
    () {
      final Response<Object?> mockResponse = Response<Object?>(
        data: {'key': 'value'},
        statusCode: 200,
        requestOptions: RequestOptions(),
      );
      String mockParserModel(final Object? data) =>
          (data as Map)['key'] as String;
      final parser = ResponseParser<Response<Object?>, String>(
        response: mockResponse,
        parserModel: mockParserModel,
      );
      test(
        'should correctly parse the response using the given parserModel',
        () {
          expect(parser.parserModel(parser.response.data), equals('value'));
        },
      );
      test(
        'should correct toString',
        () {
          expect(
            parser.toString(),
            'ResponseParser<Response<Object?>, String>(parserModel: '
            '"Closure: (Object?) => String", response: "{"key":"value"}", '
            'exception: null, stackTrace: null)',
          );
        },
      );
    },
  );
}

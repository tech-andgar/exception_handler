import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiHandler', () {
    test('should correctly pass call and parserModel to properties', () async {
      Future<Response<String>> mockApiCall() async => Response(
            data: 'test data',
            statusCode: 200,
            requestOptions: RequestOptions(),
          );
      String mockParserModel(dynamic data) => 'Parsed $data';

      final handler = ApiHandler<String>(
        call: mockApiCall,
        parserModel: mockParserModel,
      );

      expect(await handler.call(), isA<Response<dynamic>>());
      expect(handler.parserModel('data'), equals('Parsed data'));
    });
  });
  group('ResponseParser', () {
    test('should correctly parse the response using the given parserModel', () {
      final mockResponse = Response<dynamic>(
        data: {'key': 'value'},
        statusCode: 200,
        requestOptions: RequestOptions(),
      );
      String mockParserModel(dynamic data) => data['key'];

      final parser = ResponseParser<String>(
        response: mockResponse,
        parserModel: mockParserModel,
      );

      expect(parser.parserModel(parser.response.data), equals('value'));
    });
  });
}

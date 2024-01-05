import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('DioExceptionHandler Tests', () {
    final mockDio = MockDio();
    late MockApiHandler<Response, String> mockApiHandler;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockApiHandler = MockApiHandler<Response, String>();
      mockConnectivity = MockConnectivity();
      DioExceptionHandler.connectivity = mockConnectivity;
    });
    test('Successful API call returns parsed data', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'key': 'value'},
          statusCode: 200,
        ),
      );

      ResultState<String> result =
          await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (Object? data) => (data as Map)['key'],
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:String data):
          success = data;
        case FailureState<String>(:ExceptionState<String> exception):
          failure = exception;
      }

      expect(failure, isNull);
      expect(success, 'value');
    });

    test('API call with 401 status code returns unauthorized exception',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
      );

      var result = await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (Object? data) => data as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:String data):
          success = data;
        case FailureState<String>(:ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataHttpExceptionState>());
      expect(
        (failure as DataHttpExceptionState).httpException,
        HttpException.unauthorized,
      );
    });

    test('API call with no internet connection returns network exception',
        () async {
      when(() => mockApiHandler.apiCall())
          .thenThrow(DioException(requestOptions: RequestOptions()));

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final result = await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState<String>():
          fail('Expected failure but got success');
        case FailureState<String>(:ExceptionState<String> exception):
          expect(exception, isA<DataNetworkExceptionState>());
      }
    });
    test('API call with client exception', () async {
      when(() => mockDio.get(any())).thenThrow(Exception('Client Error'));

      var result = await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (Object? data) => data as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;

      switch (result) {
        case SuccessState<String>(:String data):
          success = data;
        case FailureState<String>(:ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataClientExceptionState>());
    });

    test('API call with parsing error', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'Invalid data',
          statusCode: 200,
        ),
      );

      ResultState<String> result =
          await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (Object? data) =>
              int.parse(data as String).toString(), // Intentional parse error
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      switch (result) {
        case SuccessState<String>(:String data):
          success = data;
        case FailureState<String>(:ExceptionState<String> exception):
          failure = exception;
      }

      expect(success, isNull);
      expect(failure, isA<DataParseExceptionState>());
    });

    test('should return FailureState with DataHttpException for 3xx error',
        () async {
      ResultState result = await DioExceptionHandler().callApi(
        ApiHandler(
          apiCall: () async {
            return Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 300,
            );
          },
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          expect(
            exception.httpException,
            equals(HttpException.unknownRedirect),
          );
      }
    });
    test('should return FailureState with DataHttpException for 4xx error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );
      ResultState result = await DioExceptionHandler().callApi(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpException.unknownClient),
            );
          }
      }
    });
    test('should return FailureState with DataHttpException for 404 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      );
      ResultState result = await DioExceptionHandler().callApi(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpException.notFound),
            );
          }
      }
    });

    test('should return FailureState with DataHttpException for 500 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );
      ResultState result = await DioExceptionHandler().callApi(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );
      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpException.internalServerError),
            );
          }
      }
    });
    test('should return FailureState with DataHttpException for 501 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 501,
        ),
      );
      ResultState result = await DioExceptionHandler().callApi(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpException.unknownServer),
            );
          }
      }
    });
    test('should return FailureState with DataHttpException for 600 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 600,
        ),
      );
      ResultState result = await DioExceptionHandler().callApi(
        ApiHandler(
          apiCall: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpException.unknown),
            );
          }
      }
    });

    test('handles DioException on API call', () async {
      when(() => mockApiHandler.apiCall()).thenThrow(
        MockDioException(type: DioExceptionType.connectionTimeout),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final ResultState<String> result =
          await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());

      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataNetworkExceptionState>());
          if (exception is DataNetworkExceptionState) {
            expect(
              exception.networkException,
              equals(NetworkException.timeOutException),
            );
          }
      }
      expect((result).exception, isA<DataNetworkExceptionState>());
    });
    test('handles DioExceptionType.sendTimeout on API call', () async {
      when(() => mockApiHandler.apiCall()).thenThrow(
        MockDioException(type: DioExceptionType.sendTimeout),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final ResultState<String> result =
          await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataNetworkExceptionState>());
          if (exception is DataNetworkExceptionState) {
            expect(
              exception.networkException,
              equals(NetworkException.timeOutException),
            );
          }
      }
      expect((result).exception, isA<DataNetworkExceptionState>());
    });
    test('handles DioExceptionType.unknown on API call', () async {
      when(() => mockApiHandler.apiCall()).thenThrow(
        MockDioException(type: DioExceptionType.unknown),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final ResultState<String> result =
          await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      switch (result) {
        case SuccessState():
          fail('Expected failure but got success');
        case FailureState(:ExceptionState exception):
          expect(exception, isA<DataHttpExceptionState>());
          if (exception is DataHttpExceptionState) {
            expect(
              exception.httpException,
              equals(HttpException.unknown),
            );
          }
      }
      expect((result).exception, isA<DataHttpExceptionState>());
    });

    test('handles general exception on API call', () async {
      final exception = Exception('General error');
      when(() => mockApiHandler.apiCall()).thenThrow(exception);
      final result =
          await DioExceptionHandler().callApi<Response, String>(mockApiHandler);

      expect(result, isA<FailureState>());
      expect(
        (result as FailureState).exception,
        isA<DataClientExceptionState>(),
      );
    });
  });
}

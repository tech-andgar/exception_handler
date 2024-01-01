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

      TaskResult<String> result =
          await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (Object? data) => (data as Map)['key'],
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      result.when(
        success: (String data) {
          success = data;
        },
        failure: (ExceptionState<String> exception) {
          failure = exception;
        },
      );

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
          call: () => mockDio.get('test'),
          parserModel: (Object? data) => data as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      result.when(
        success: (String data) {
          success = data;
        },
        failure: (ExceptionState<String> exception) {
          failure = exception;
        },
      );

      expect(success, isNull);
      expect(failure, isA<DataHttpException>());
      expect(
        (failure as DataHttpException).httpException,
        HttpException.unauthorized,
      );
    });

    test('API call with no internet connection returns network exception',
        () async {
      when(() => mockApiHandler.call())
          .thenThrow(DioException(requestOptions: RequestOptions()));

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      final result = await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) => expect(exception, isA<DataNetworkException>()),
      );
    });
    test('API call with client exception', () async {
      when(() => mockDio.get(any())).thenThrow(Exception('Client Error'));

      var result = await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (Object? data) => data as String,
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      result.when(
        success: (String data) {
          success = data;
        },
        failure: (ExceptionState<String> exception) {
          failure = exception;
        },
      );

      expect(success, isNull);
      expect(failure, isA<DataClientException>());
    });

    test('API call with parsing error', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: 'Invalid data',
          statusCode: 200,
        ),
      );

      TaskResult<String> result =
          await DioExceptionHandler().callApi<Response, String>(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (Object? data) =>
              int.parse(data as String).toString(), // Intentional parse error
        ),
      );

      String? success;
      ExceptionState<String>? failure;
      result.when(
        success: (String data) {
          success = data;
        },
        failure: (ExceptionState<String> exception) {
          failure = exception;
        },
      );

      expect(success, isNull);
      expect(failure, isA<DataParseException>());
    });

    test('should return FailureState with DataHttpException for 3xx error',
        () async {
      TaskResult result = await DioExceptionHandler().callApi(
        ApiHandler(
          call: () async {
            return Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 300,
            );
          },
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (ExceptionState exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.unknownRedirect),
            );
          }
        },
      );
    });
    test('should return FailureState with DataHttpException for 4xx error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );
      TaskResult result = await DioExceptionHandler().callApi(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.unknownClient),
            );
          }
        },
      );
    });
    test('should return FailureState with DataHttpException for 404 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      );
      TaskResult result = await DioExceptionHandler().callApi(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.notFound),
            );
          }
        },
      );
    });

    test('should return FailureState with DataHttpException for 500 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
      );
      TaskResult result = await DioExceptionHandler().callApi(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );
      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.internalServerError),
            );
          }
        },
      );
    });
    test('should return FailureState with DataHttpException for 501 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 501,
        ),
      );
      TaskResult result = await DioExceptionHandler().callApi(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.unknownServer),
            );
          }
        },
      );
    });
    test('should return FailureState with DataHttpException for 600 error',
        () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 600,
        ),
      );
      TaskResult result = await DioExceptionHandler().callApi(
        ApiHandler(
          call: () => mockDio.get('test'),
          parserModel: (res) {},
        ),
      );

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.unknown),
            );
          }
        },
      );
    });

    test('handles DioException on API call', () async {
      when(() => mockApiHandler.call()).thenThrow(
        MockDioException(type: DioExceptionType.connectionTimeout),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final TaskResult<String> result =
          await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataNetworkException>());
          if (exception is DataNetworkException) {
            expect(
              exception.networkException,
              equals(NetworkException.timeOutException),
            );
          }
        },
      );
      expect((result as FailureState).exception, isA<DataNetworkException>());
    });
    test('handles DioExceptionType.sendTimeout on API call', () async {
      when(() => mockApiHandler.call()).thenThrow(
        MockDioException(type: DioExceptionType.sendTimeout),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final TaskResult<String> result =
          await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataNetworkException>());
          if (exception is DataNetworkException) {
            expect(
              exception.networkException,
              equals(NetworkException.timeOutException),
            );
          }
        },
      );
      expect((result as FailureState).exception, isA<DataNetworkException>());
    });
    test('handles DioExceptionType.unknown on API call', () async {
      when(() => mockApiHandler.call()).thenThrow(
        MockDioException(type: DioExceptionType.unknown),
      );

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);

      final TaskResult<String> result =
          await DioExceptionHandler().callApi(mockApiHandler);

      expect(result, isA<FailureState>());
      result.when(
        success: (_) => fail('Expected failure but got success'),
        failure: (exception) {
          expect(exception, isA<DataHttpException>());
          if (exception is DataHttpException) {
            expect(
              exception.httpException,
              equals(HttpException.unknown),
            );
          }
        },
      );
      expect((result as FailureState).exception, isA<DataHttpException>());
    });

    test('handles general exception on API call', () async {
      final exception = Exception('General error');
      when(() => mockApiHandler.call()).thenThrow(exception);
      final result =
          await DioExceptionHandler().callApi<Response, String>(mockApiHandler);

      expect(result, isA<FailureState>());
      expect((result as FailureState).exception, isA<DataClientException>());
    });
  });
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_exception/http_exception.dart';
import 'package:http_status/http_status.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'DioExceptionHandler Tests',
    () {
      final mockDio = MockDio();
      late MockApiHandler<Response<Object>, String> mockApiHandler;
      late MockConnectivity mockConnectivity;

      setUp(
        () {
          mockApiHandler = MockApiHandler<Response<Object>, String>();
          mockConnectivity = MockConnectivity();
          DioExceptionHandler.connectivity = mockConnectivity;
        },
      );
      test(
        'Successful API call returns parsed data',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {'key': 'value'},
              statusCode: 200,
            ),
          );

          final Result<String> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final Object? data) =>
                  (data as Map)['key'] as String,
            ),
          );

          String? success;
          ExceptionState<String>? failure;
          switch (result) {
            case Ok<String>(:final String value):
              success = value;
            case Error<String>(:final ExceptionState<String> error):
              failure = error;
          }

          expect(failure, isNull);
          expect(success, 'value');
        },
      );

      test(
        'API call with 401 status code returns unauthorized exception',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 401,
            ),
          );

          final result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final Object? data) => data as String,
            ),
          );

          String? success;
          ExceptionState<String>? failure;
          switch (result) {
            case Ok<String>(:final String value):
              success = value;
            case Error<String>(:final ExceptionState<String> error):
              failure = error;
          }

          expect(success, isNull);
          expect(failure, isA<DataHttpExceptionState<Object?>>());
          expect(
            (failure as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(401).exception(),
          );
        },
      );

      test(
        'API call with no internet connection returns network exception',
        () async {
          when(() => mockApiHandler.apiCall())
              .thenThrow(DioException(requestOptions: RequestOptions()));

          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((final _) async => [ConnectivityResult.none]);

          final result = await DioExceptionHandler.callApi_(mockApiHandler);

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok<String>():
              fail('Expected failure but got success');
            case Error<String>(:final ExceptionState<String> error):
              expect(error, isA<DataNetworkExceptionState<Object?>>());
          }
        },
      );
      test(
        'API call with client exception',
        () async {
          when(() => mockDio.get<Object>(any()))
              .thenThrow(Exception('Client Error'));

          final result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final Object? data) => data as String,
            ),
          );

          String? success;
          ExceptionState<String>? failure;

          switch (result) {
            case Ok<String>(:final String value):
              success = value;
            case Error<String>(:final ExceptionState<String> error):
              failure = error;
          }

          expect(success, isNull);
          expect(failure, isA<DataClientExceptionState<Object?>>());
        },
      );

      test(
        'API call with parsing error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: 'Invalid data',
              statusCode: 200,
            ),
          );

          final Result<String> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final Object? data) => int.parse(data as String)
                  .toString(), // Intentional parse error
            ),
          );

          String? success;
          ExceptionState<String>? failure;
          switch (result) {
            case Ok<String>(:final String value):
              success = value;
            case Error<String>(:final ExceptionState<String> error):
              failure = error;
          }

          expect(success, isNull);
          expect(failure, isA<DataParseExceptionState<Object?>>());
        },
      );

      test(
        'should return Error with DataHttpException for 3xx error',
        () async {
          final Result<Object?> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () async => Response<Object>(
                requestOptions: RequestOptions(path: ''),
                statusCode: 300,
              ),
              parserModel: (final res) => null,
            ),
          );

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              expect(
                (error as DataHttpExceptionState).httpException,
                equals(HttpStatus.fromCode(300).exception()),
              );
          }
        },
      );
      test(
        'should return Error with DataHttpException for 4xx error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 400,
            ),
          );
          final Result<Object?> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final res) => null,
            ),
          );

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              if (error is DataHttpExceptionState) {
                expect(
                  error.httpException,
                  equals(HttpStatus.fromCode(400).exception()),
                );
              }
          }
        },
      );
      test(
        'should return Error with DataHttpException for 404 error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 404,
            ),
          );
          final Result<Object?> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final res) => null,
            ),
          );

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              if (error is DataHttpExceptionState) {
                expect(
                  error.httpException,
                  equals(HttpStatus.fromCode(404).exception()),
                );
              }
          }
        },
      );

      test(
        'should return Error with DataHttpException for 500 error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
            ),
          );
          final Result<Object?> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final res) => null,
            ),
          );
          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              if (error is DataHttpExceptionState) {
                expect(
                    error.httpException,
                  equals(HttpStatus.fromCode(500).exception()),
                );
              }
          }
        },
      );
      test(
        'should return Error with DataHttpException for 501 error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 501,
            ),
          );
          final Result<Object?> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final res) => null,
            ),
          );

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              if (error is DataHttpExceptionState) {
                expect(
                  error.httpException,
                  equals(HttpStatus.fromCode(501).exception()),
                );
              }
          }
        },
      );
      test(
        'should return Error with DataHttpException for 600 error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 600,
            ),
          );
          final Result<Object?> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final res) => null,
            ),
          );

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              if (error is DataHttpExceptionState) {
                expect(
                  error.httpException,
                  equals(
                    HttpException(
                      httpStatus: HttpStatus(
                        code: 600,
                        name: 'unknown_HttpStatus',
                        description: 'unknown_description',
                      ),
                      detail:
                          'exception: Invalid argument (code): Unrecognized status code. Use the HttpStatus constructor for custom codes: 600',
                    ),
                  ),
                );
              }
          }
        },
      );

      test(
        'handles DioException on API call',
        () async {
          when(() => mockApiHandler.apiCall()).thenThrow(
            MockDioException(type: DioExceptionType.connectionTimeout),
          );

          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((final _) async => [ConnectivityResult.wifi]);

          final Result<String> result =
              await DioExceptionHandler.callApi_(mockApiHandler);

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataNetworkExceptionState<Object?>>());
              if (error is DataNetworkExceptionState) {
                expect(
                  error.message,
                  equals('NetworkException.timeOutException'),
                );
              }
          }
          expect(result.error, isA<DataNetworkExceptionState<Object?>>());
        },
      );
      test(
        'handles DioExceptionType.sendTimeout on API call',
        () async {
          when(() => mockApiHandler.apiCall()).thenThrow(
            MockDioException(type: DioExceptionType.sendTimeout),
          );

          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((final _) async => [ConnectivityResult.wifi]);

          final Result<String> result =
              await DioExceptionHandler.callApi_(mockApiHandler);

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataNetworkExceptionState<Object?>>());
              if (error is DataNetworkExceptionState) {
                expect(
                  error.message,
                  equals('NetworkException.sendTimeout'),
                );
              }
          }
          expect(result.error, isA<DataNetworkExceptionState<Object?>>());
        },
      );
      test(
        'handles DioExceptionType.unknown on API call',
        () async {
          when(() => mockApiHandler.apiCall()).thenThrow(
            MockDioException(type: DioExceptionType.unknown),
          );

          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((final _) async => [ConnectivityResult.wifi]);

          final Result<String> result =
              await DioExceptionHandler.callApi_(mockApiHandler);

          expect(result, isA<Error<Object?>>());

          switch (result) {
            case Ok():
              fail('Expected failure but got success');
            case Error(:final ExceptionState<Object?> error):
              expect(error, isA<DataHttpExceptionState<Object?>>());
              if (error is DataHttpExceptionState) {
                expect(
                  error.httpException,
                  equals(
                    HttpException(
                      httpStatus: HttpStatus(
                        code: 0,
                        name: 'unknown_HttpStatus',
                        description: 'unknown_description',
                      ),
                      detail: '',
                    ),
                  ),
                );
              }
          }
          expect(result.error, isA<DataHttpExceptionState<Object?>>());
        },
      );

      test(
        'handles general exception on API call',
        () async {
          final exception = Exception('General error');
          when(() => mockApiHandler.apiCall()).thenThrow(exception);
          final result = await DioExceptionHandler.callApi_(mockApiHandler);

          expect(result, isA<Error<Object?>>());
          expect(
            (result as Error<Object?>).error,
            isA<DataClientExceptionState<Object?>>(),
          );
        },
      );
      test(
        'API call with unknown error',
        () async {
          when(() => mockDio.get<Object>(any())).thenAnswer(
            (final _) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: 'Invalid data',
              statusCode: 200,
            ),
          );

          final Result<String> result = await DioExceptionHandler.callApi_(
            ApiHandler(
              apiCall: () => mockDio.get<Object>('test'),
              parserModel: (final Object? data) {
                throw Exception('Error Unknown'); // Intentional error
              },
            ),
          );

          String? success;
          ExceptionState<String>? failure;
          switch (result) {
            case Ok<String>(:final String value):
              success = value;
            case Error<String>(:final ExceptionState<String> error):
              failure = error;
          }

          expect(success, isNull);
          expect(failure, isA<DataUnknownExceptionState<Object?>>());
        },
      );
    },
  );
}

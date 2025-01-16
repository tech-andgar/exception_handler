import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_exception/http_exception.dart';
import 'package:http_status/http_status.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
  });

  factory UserModel.fromJson(final Map<String, Object?> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
      );

  final int id;
  final String name;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HttpResponseDioExtension', () {
    final requestOptions =
        RequestOptions(path: '/data', validateStatus: (final status) => true);

    final data = {'id': 1, 'name': 'John Doe'};

    final dataList = [
      {'id': 1, 'name': 'John Doe'},
      {'id': 2, 'name': 'Jane Doe'},
    ];

    Future<Never> futureDioException(
      final DioExceptionType type, {
      final Response<Object?>? response,
    }) =>
        Future.delayed(
          const Duration(microseconds: 10),
          () => throw DioException(
            response: response,
            requestOptions: requestOptions,
            type: type,
          ),
        );

    late MockConnectivity mockConnectivity;

    setUp(() {
      mockConnectivity = MockConnectivity();
      DioExceptionHandler.connectivity = mockConnectivity;
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((final _) async => [ConnectivityResult.mobile]);
    });

    group('fromJson', () {
      test(
        'should return Ok<UserModel> when conversion is successful',
        () async {
          // Arrange
          final dioResponse = Response<Map<String, Object?>>(
            data: data,
            statusCode: 200,
            requestOptions: requestOptions,
          );

          // Act
          final result =
              await Future.value(dioResponse).fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Ok<UserModel>>());
          expect(
            (result as Ok<UserModel>).value,
            isA<UserModel>(),
          );
        },
      );

      test(
        'should return Error DataParseExceptionState when conversion fails',
        () async {
          // Arrange
          final dioResponse = Response<Map<String, Object?>>(
            data: {'id': 'invalid', 'name': 'John Doe'},
            statusCode: 200,
            requestOptions: requestOptions,
          );

          // Act
          final result =
              await Future.value(dioResponse).fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataParseExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataParseExceptionState<UserModel>(parseException: "type \'String\' is not a subtype of type \'int\' in type cast")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.connectionTimeout on DioExceptionType.connectionTimeout',
        () async {
          // Arrange
          final dioResponse =
              futureDioException(DioExceptionType.connectionTimeout);

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<UserModel>(networkException: "NetworkException.timeOutException")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.sendTimeout on DioExceptionType.sendTimeout',
        () async {
          // Arrange
          final dioResponse = futureDioException(DioExceptionType.sendTimeout);

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<UserModel>(networkException: "NetworkException.sendTimeout")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.requestCancel on DioExceptionType.cancel',
        () async {
          // Arrange
          final dioResponse = futureDioException(DioExceptionType.cancel);

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<UserModel>(networkException: "NetworkException.cancel")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.receiveTimeout on DioExceptionType.receiveTimeout',
        () async {
          // Arrange
          final dioResponse =
              futureDioException(DioExceptionType.receiveTimeout);

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<UserModel>(networkException: "NetworkException.receiveTimeout")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.noInternetConnection on DioExceptionType.connectionError',
        () async {
          // Arrange
          final dioResponse =
              futureDioException(DioExceptionType.connectionError);

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<UserModel>(networkException: "NetworkException.noInternetConnection")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.unknown on DioExceptionType.unknown',
        () async {
          // Arrange
          final dioResponse = futureDioException(DioExceptionType.unknown);

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpException(
              httpStatus: HttpStatus(
                code: 0,
                name: 'unknown_HttpStatus',
                description: 'unknown_description',
              ),
              detail: '',
            ),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<UserModel>(httpException: HttpException [0 unknown_HttpStatus]: exception: Invalid argument (code): Unrecognized status code. Use the HttpStatus constructor for custom codes: 0, message: "DioException [unknown]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException on DioExceptionType.badResponse with status code null',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != null,
              ),
              statusCode: null,
            ),
          );

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpException(
              httpStatus: HttpStatus(
                code: 0,
                name: 'unknown_HttpStatus',
                description: 'unknown_description',
              ),
              detail: '',
            ),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<UserModel>(httpException: HttpException [0 unknown_HttpStatus]: exception: Invalid argument (code): Unrecognized status code. Use the HttpStatus constructor for custom codes: 0, message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException on status code 100',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 100,
              ),
              statusCode: 100,
            ),
          );

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(100).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<UserModel>(httpException: HttpException [100 Continue], message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException.multipleChoices on status code 300',
        () async {
          // Arrange

          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 300,
              ),
              statusCode: 300,
            ),
          );

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );

          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(300).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<UserModel>(httpException: HttpException [300 Multiple Choices], message: "DioException [bad response]: null")',
          );
        },
      );
      test(
        'should return Error.DataHttpExceptionState.httpException.badRequest on status code 400',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 400,
              ),
              statusCode: 400,
            ),
          );

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );

          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(400).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<UserModel>(httpException: HttpException [400 Bad Request], message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException.internalServerError on status code 500',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 500,
              ),
              statusCode: 500,
            ),
          );

          // Act
          final result = await dioResponse.fromJson(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<UserModel>>());
          expect(
            (result as Error<UserModel>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(500).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<UserModel>(httpException: HttpException [500 Internal Server Error], message: "DioException [bad response]: null")',
          );
        },
      );
    });

    group('fromJsonAsList', () {
      test(
        'should return Ok<List<UserModel>> when conversion is successful',
        () async {
          // Arrange

          final dioResponse = Response<List<Object?>>(
            data: dataList,
            statusCode: 200,
            requestOptions: requestOptions,
          );

          // Act
          final result = await Future.value(dioResponse)
              .fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Ok<List<UserModel>>>());
          expect(
            (result as Ok<List<UserModel>>).value,
            isA<List<UserModel>>(),
          );
          expect(result.value.length, 2);
        },
      );

      test(
        'should return Error DataParseExceptionState when conversion fails for at least one field',
        () async {
          // Arrange
          final dioResponse = Response<List<Object?>>(
            data: [
              {'id': 1, 'name': 'John Doe'},
              {'id': 'invalid', 'name': 'Jane Doe'},
            ],
            statusCode: 200,
            requestOptions: requestOptions,
          );

          // Act
          final result = await Future.value(dioResponse)
              .fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataParseExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataParseExceptionState<List<UserModel>>(parseException: "type \'List<Object?>\' is not a subtype of type \'List<Map<String, dynamic>>\' in type cast")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.connectionTimeout on DioExceptionType.connectionTimeout',
        () async {
          // Arrange
          final dioResponse =
              futureDioException(DioExceptionType.connectionTimeout);

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<List<UserModel>>(networkException: "NetworkException.timeOutException")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.sendTimeout on DioExceptionType.sendTimeout',
        () async {
          // Arrange
          final dioResponse = futureDioException(DioExceptionType.sendTimeout);

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(
            result as Error<List<UserModel>>,
            isA<Error<List<UserModel>>>(),
          );
          expect(
            result.error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<List<UserModel>>(networkException: "NetworkException.sendTimeout")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.requestCancel on DioExceptionType.cancel',
        () async {
          // Arrange
          final dioResponse = futureDioException(DioExceptionType.cancel);

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<List<UserModel>>(networkException: "NetworkException.cancel")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.receiveTimeout on DioExceptionType.receiveTimeout',
        () async {
          // Arrange
          final dioResponse =
              futureDioException(DioExceptionType.receiveTimeout);

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<List<UserModel>>(networkException: "NetworkException.receiveTimeout")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.noInternetConnection on DioExceptionType.connectionError',
        () async {
          // Arrange
          final dioResponse =
              futureDioException(DioExceptionType.connectionError);

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataNetworkExceptionState<Object?>>(),
          );
          expect(
            result.error.toString(),
            'DataNetworkExceptionState<List<UserModel>>(networkException: "NetworkException.noInternetConnection")',
          );
        },
      );

      test(
        'should return Error DataNetworkExceptionState.NetworkException.unknown on DioExceptionType.unknown',
        () async {
          // Arrange
          final dioResponse = futureDioException(DioExceptionType.unknown);

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpException(
              httpStatus: HttpStatus(
                code: 0,
                name: 'unknown_HttpStatus',
                description: 'unknown_description',
              ),
              detail: '',
            ),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<List<UserModel>>(httpException: HttpException [0 unknown_HttpStatus]: exception: Invalid argument (code): Unrecognized status code. Use the HttpStatus constructor for custom codes: 0, message: "DioException [unknown]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException on DioExceptionType.badResponse with status code null',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != null,
              ),
              statusCode: null,
            ),
          );

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpException(
              httpStatus: HttpStatus(
                code: 0,
                name: 'unknown_HttpStatus',
                description: 'unknown_description',
              ),
              detail: '',
            ),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<List<UserModel>>(httpException: HttpException [0 unknown_HttpStatus]: exception: Invalid argument (code): Unrecognized status code. Use the HttpStatus constructor for custom codes: 0, message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error<HttpFailure.informationalResponse> on status code 100',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 100,
              ),
              statusCode: 100,
            ),
          );

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(100).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<List<UserModel>>(httpException: HttpException [100 Continue], message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException.unknownRedirect on status code 300',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 300,
              ),
              statusCode: 300,
            ),
          );

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(300).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<List<UserModel>>(httpException: HttpException [300 Multiple Choices], message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException.unknownClient on status code 400',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 400,
              ),
              statusCode: 400,
            ),
          );

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(400).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<List<UserModel>>(httpException: HttpException [400 Bad Request], message: "DioException [bad response]: null")',
          );
        },
      );

      test(
        'should return Error.DataHttpExceptionState.httpException.internalServerError on status code 500',
        () async {
          // Arrange
          final dioResponse = futureDioException(
            DioExceptionType.badResponse,
            response: Response<Map<String, Object?>>(
              requestOptions: RequestOptions(
                validateStatus: (final status) => status != 500,
              ),
              statusCode: 500,
            ),
          );

          // Act
          final result = await dioResponse.fromJsonAsList(UserModel.fromJson);

          // Assert
          expect(result, isA<Error<List<UserModel>>>());
          expect(
            (result as Error<List<UserModel>>).error,
            isA<DataHttpExceptionState<Object?>>(),
          );
          expect(
            (result.error as DataHttpExceptionState).httpException,
            HttpStatus.fromCode(500).exception(),
          );
          expect(
            result.error.toString(),
            'DataHttpExceptionState<List<UserModel>>(httpException: HttpException [500 Internal Server Error], message: "DioException [bad response]: null")',
          );
        },
      );
    });
  });
}

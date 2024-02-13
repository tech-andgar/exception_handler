import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../exception_state/exception_state.dart';
import '../../result_state/result_state.dart';
import '../../utils/utils.dart';
import '../exception_handler_client.dart';

class DioExceptionHandler extends ClientExceptionHandler {
  static Connectivity connectivity = Connectivity();

  /// callApi is a generic method to handle API calls and return a tuple of
  /// ExceptionState and parsed data.
  ///
  /// Eg:
  /// ```dart
  /// final ResultState<UserModel> result =
  ///        await DioExceptionHandler().callApi<Response, UserModel>(
  ///      ApiHandler(
  ///        apiCall: () {
  ///          return dio.get('https://jsonplaceholder.typicode.com/users/$id');
  ///        },
  ///        parserModel: (Object? data) =>
  ///            UserModel.fromJson(data as Map<String, dynamic>),
  ///      ),
  ///    );
  /// ```
  @override
  Future<ResultState<TModel>> callApi<Response, TModel>(
    ApiHandler<Response, TModel> apiHandler,
  ) async {
    try {
      final Response response = await apiHandler.apiCall();

      Future<ResultState<TModel>> handleHttpResponse =
          _handleHttpResponse<TModel>(
      );
    } on DioException catch (e, s) {
      if (!await _isConnected()) {
        return FailureState(
          DataNetworkExceptionState<TModel>(
            NetworkException.noInternetConnection,
            s,
          ),
        );
      }
      return _handleDioException<TModel>(e, s);
    } on Exception catch (e, s) {
      return FailureState(DataClientExceptionState<TModel>(e, s));
    }
  }

  /// _isConnected checks the current network connectivity status.
  static Future<bool> _isConnected() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// _handleHttpResponse processes the HTTP response and handles different
  /// status codes.
  static Future<ResultState<TModel>> _handleHttpResponse<TModel>(
    ResponseParser responseParser,
  ) async {
    int? statusCode = responseParser.response.statusCode;

    return await _handleStatusCode<TModel>(statusCode, responseParser);
  }

  static Future<ResultState<TModel>> _handleStatusCode<TModel>(
    int? statusCode,
    ResponseParser responseParser,
  ) async {
    return switch (statusCode) {
      int statusCode when statusCode.isBetween(200, 299) =>
        await _handle2xxparseResponse<TModel>(responseParser),
      int statusCode when statusCode.isBetween(300, 399) =>
        _handle3xxRedirect<TModel>(statusCode, responseParser),
      int statusCode when statusCode.isBetween(400, 499) =>
        _handle4xxClientError<TModel>(statusCode, responseParser),
      int statusCode when statusCode.isBetween(500, 599) =>
        _handle5xxServerError<TModel>(statusCode, responseParser),
      _ => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.unknown,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        ),
    };
  }

  /// _parseResponse tries to parse the response and handle any parsing
  /// exceptions.
  static Future<ResultState<TModel>> _handle2xxparseResponse<TModel>(
    ResponseParser responseParser,
  ) async {
    try {
      TModel dataModelParsed = await compute(
        responseParser.parserModel as ParseFunction<TModel>,
        responseParser.response.data,
      );

        return SuccessState(dataModelParsed);
      } catch (e, s) {
        return FailureState(DataParseExceptionState<TModel>(Exception(e), s));
      }
    }
  }

  static FailureState<TModel> _handle3xxRedirect<TModel>(
    int statusCode,
    ResponseParser responseParser,
  ) {
    return switch (statusCode) {
      _ => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.unknownRedirect,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        )
    };
  }

  static FailureState<TModel> _handle4xxClientError<TModel>(
    int statusCode,
    ResponseParser responseParser,
  ) {
    return switch (statusCode) {
      401 => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.unauthorized,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        ),
      404 => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.notFound,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        ),
      _ => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.unknownClient,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        )
    };
  }

  static FailureState<TModel> _handle5xxServerError<TModel>(
    int statusCode,
    ResponseParser responseParser,
  ) {
    return switch (statusCode) {
      500 => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.internalServerError,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        ),
      _ => FailureState(
          DataHttpExceptionState<TModel>(
            exception: responseParser.exception,
            httpException: HttpException.unknownServer,
            stackTrace: StackTrace.current,
            statusCode: statusCode,
          ),
        )
    };
  }

  /// _handleDioException handles exceptions from the Dio library,
  /// particularly around connectivity.
  static Future<ResultState<TModel>> _handleDioException<TModel>(
    DioException e,
    StackTrace s,
  ) async {
    const String start =
        'This exception was thrown because the response has a status code of ';
    const String end =
        'and RequestOptions.validateStatus was configured to throw for this status code.';
    final int? statusCode =
        int.tryParse(e.message.toString().split(start).last.split(end).first);

    return switch (e.type) {
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout =>
        FailureState(
          DataNetworkExceptionState<TModel>(NetworkException.timeOutException, s),
        ),
      _ => await _handleStatusCode(
          statusCode,
          ResponseParser(
            response: Response(requestOptions: RequestOptions()),
            // coverage:ignore-start
            parserModel: (_) {},
            // coverage:ignore-end
            exception: e,
            stackTrace: s,
          ),
        ),
    };
  }
}

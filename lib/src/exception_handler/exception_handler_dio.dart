import 'dart:async';
import 'dart:isolate';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../exception_state/exception_state.dart';
import '../task_result/task_result.dart';
import '../utils/utils.dart';
import 'exception_handler_client.dart';

class DioExceptionHandler extends ClientExceptionHandler {
  static Connectivity connectivity = Connectivity();

  /// callApi is a generic method to handle API calls and return a tuple of
  /// ExceptionState and parsed data.
  ///
  /// Eg:
  /// ```dart
  /// final TaskResult<UserModel> result =
  ///        await DioExceptionHandler().callApi<Response, UserModel>(
  ///      ApiHandler(
  ///        call: () {
  ///          return dio.get('https://jsonplaceholder.typicode.com/users/$id');
  ///        },
  ///        parserModel: (Object? data) =>
  ///            UserModel.fromJson(data as Map<String, dynamic>),
  ///      ),
  ///    );
  /// ```
  @override
  Future<TaskResult<T>> callApi<Response, T>(
    ApiHandler<Response, T> apiHandler,
  ) async {
    try {
      final Response response = await apiHandler.call();

      return _handleHttpResponse<T>(
        ResponseParser(response: response, parserModel: apiHandler.parserModel),
      );
    } on DioException catch (e, s) {
      if (!await _isConnected()) {
        return FailureState(
          DataNetworkException<T>(NetworkException.noInternetConnection, s),
        );
      }
      return _handleDioException<T>(e, s);
    } on Exception catch (e, s) {
      return FailureState(DataClientException<T>(e, s));
    }
  }

  /// _isConnected checks the current network connectivity status.
  static Future<bool> _isConnected() async {
    ConnectivityResult result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// _handleHttpResponse processes the HTTP response and handles different
  /// status codes.
  static Future<TaskResult<T>> _handleHttpResponse<T>(
    ResponseParser responseParser,
  ) async {
    int? statusCode = responseParser.response.statusCode;

    return await _handlestatusCode<T>(statusCode, responseParser);
  }

  static Future<TaskResult<T>> _handlestatusCode<T>(
    int? statusCode,
    ResponseParser responseParser,
  ) async {
    return switch (statusCode) {
      int statusCode when statusCode.isBetween(200, 299) =>
        await _handle2xxparseResponse<T>(responseParser),
      int statusCode when statusCode.isBetween(300, 399) =>
        _handle3xxRedirect<T>(statusCode, responseParser),
      int statusCode when statusCode.isBetween(400, 499) =>
        _handle4xxClientError<T>(statusCode, responseParser),
      int statusCode when statusCode.isBetween(500, 599) =>
        _handle5xxServerError<T>(statusCode, responseParser),
      _ => FailureState(
          DataHttpException<T>(
            HttpException.unknown,
            responseParser.exception,
            StackTrace.current,
          ),
        ),
    };
  }

  /// _parseResponse tries to parse the response and handle any parsing
  /// exceptions.
  static Future<TaskResult<T>> _handle2xxparseResponse<T>(
    ResponseParser responseParser,
  ) async {
    try {
      T dataModelParsed = await Isolate.run(
        () => responseParser.parserModel(responseParser.response.data),
        debugName:
            kReleaseMode ? 'compute' : responseParser.parserModel.toString(),
      );

      return SuccessState(dataModelParsed);
    } catch (e, s) {
      return FailureState(DataParseException<T>(Exception(e), s));
    }
  }

  static FailureState<T> _handle3xxRedirect<T>(
    int statusCode,
    ResponseParser responseParser,
  ) {
    return switch (statusCode) {
      _ => FailureState(
          DataHttpException<T>(
            HttpException.unknownRedirect,
            responseParser.exception,
            StackTrace.current,
          ),
        )
    };
  }

  static FailureState<T> _handle4xxClientError<T>(
    int statusCode,
    ResponseParser responseParser,
  ) {
    return switch (statusCode) {
      401 => FailureState(
          DataHttpException<T>(
            HttpException.unauthorized,
            responseParser.exception,
            StackTrace.current,
          ),
        ),
      404 => FailureState(
          DataHttpException<T>(
            HttpException.badResponse,
            responseParser.exception,
            StackTrace.current,
          ),
        ),
      _ => FailureState(
          DataHttpException<T>(
            HttpException.unknownClient,
            responseParser.exception,
            StackTrace.current,
          ),
        )
    };
  }

  static FailureState<T> _handle5xxServerError<T>(
    int statusCode,
    ResponseParser responseParser,
  ) {
    return switch (statusCode) {
      500 => FailureState(
          DataHttpException<T>(
            HttpException.internalServerError,
            responseParser.exception,
            StackTrace.current,
          ),
        ),
      _ => FailureState(
          DataHttpException<T>(
            HttpException.unknownServer,
            responseParser.exception,
            StackTrace.current,
          ),
        )
    };
  }

  /// _handleDioException handles exceptions from the Dio library,
  /// particularly around connectivity.
  static Future<TaskResult<T>> _handleDioException<T>(
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
          DataNetworkException<T>(NetworkException.timeOutException, s),
        ),
      _ => await _handlestatusCode(
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

// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_status/http_status.dart';

import '../../exception_state/exceptions_state.dart';
import '../../result_state/result_state.dart';
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
        ResponseParser(
          response: response,
          parserModel: apiHandler.parserModel,
        ),
      );

      return handleHttpResponse;
    } on DioException catch (e, s) {
      if (!await _isConnected() || e.type == DioExceptionType.connectionError) {
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
      int statusCode when statusCode.isSuccessfulHttpStatusCode =>
        await _handle2xxparseResponse<TModel>(responseParser),
      int statusCode when statusCode.isRedirectHttpStatusCode =>
        _handle3xxRedirect<TModel>(statusCode, responseParser),
      int statusCode when statusCode.isClientErrorHttpStatusCode =>
        _handle4xxClientError<TModel>(statusCode, responseParser),
      int statusCode when statusCode.isServerErrorHttpStatusCode =>
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
    } catch (e) {
      try {
        // TODO(andgar2010): need more investigation about compute error on platform windows
        log(
          '''
Handle error compute.
Error: $e
Change mode async isolate to sync''',
          name: 'DioExceptionHandler._handle2xxparseResponse',
        );
        final TModel dataModelParsed =
            responseParser.parserModel(responseParser.response.data);
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
        int.tryParse(e.message.toString().split(start).last.split(end).first) ??
            e.response?.statusCode;

    if (statusCode != null) {
      return await _handleStatusCode(
        statusCode,
        ResponseParser(
          response: Response(requestOptions: RequestOptions()),
          // coverage:ignore-start
          parserModel: (_) {},
          // coverage:ignore-end
          exception: e,
          stackTrace: s,
        ),
      );
    } else {
      return switch (e.type) {
        DioExceptionType.connectionTimeout => FailureState(
            DataNetworkExceptionState<TModel>(
              NetworkException.timeOutException,
              s,
            ),
          ),
        DioExceptionType.receiveTimeout => FailureState(
            DataNetworkExceptionState<TModel>(
              NetworkException.receiveTimeout,
              s,
            ),
          ),
        DioExceptionType.cancel => FailureState(
            DataNetworkExceptionState<TModel>(
              NetworkException.cancel,
              s,
            ),
          ),
        DioExceptionType.sendTimeout => FailureState(
            DataNetworkExceptionState<TModel>(
              NetworkException.sendTimeout,
              s,
            ),
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
}

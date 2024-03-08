// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:http_exception/http_exception.dart';
import 'package:http_status/http_status.dart';

import '../../../exception_handler.dart';

/// handleHttpGenericParseResponseDio tries to parse the response and handle
/// any parsing exceptions.
Future<ResultState<TModel>> handleHttpGenericParseResponseDio<Response, TModel>(
  int statusCode,
  ResponseParser<Response, TModel> responseParser,
) async {
  try {
    final FailureState<TModel> failureState = FailureState(
      DataHttpExceptionState<TModel>(
        exception: responseParser.exception,
        httpException: HttpStatus.fromCode(statusCode).exception(),
        stackTrace: StackTrace.current,
      ),
    );
    return failureState;
  } catch (e) {
    return FailureState(
      DataHttpExceptionState<TModel>(
        exception: responseParser.exception,
        httpException: HttpException(
          httpStatus: HttpStatus(
            code: statusCode,
            name: 'unknown_HttpStatus',
            description: 'unknown_description',
          ),
          detail: 'exception: $e',
        ),
        stackTrace: StackTrace.current,
      ),
    );
  }
}

/// handleHttp2xxParseResponseDio tries to parse the response and handle
/// any parsing exceptions.
Future<ResultState<TModel>> handleHttp2xxParseResponseDio<TModel>(
  ResponseParser<Response, TModel> responseParser,
) async {
  try {
    final TModel dataModelParsed = await compute(
      responseParser.parserModel,
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
    } on FormatException catch (e, s) {
      return FailureState(DataParseExceptionState<TModel>(e.toString(), s));
    } on TypeError catch (e, s) {
      return FailureState(DataParseExceptionState<TModel>(e.toString(), s));
    } catch (e, s) {
      return FailureState(DataUnknownExceptionState<TModel>(e.toString(), s));
    }
  }
}

class DioExceptionHandler extends ClientExceptionHandler {
  static Connectivity connectivity = Connectivity();
  late HandleHttpParseResponse handleParseResponse_;

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
    ApiHandler<Response, TModel> apiHandler, {
    HandleHttpParseResponse<Response, TModel>? handleHttpParseResponse,
  }) async {
    handleParseResponse_ = handleHttpParseResponse ??
        HandleHttpParseResponse<Response, TModel>(
          handleHttp1xxParseResponse: handleHttpGenericParseResponseDio,
          // handleHttp2xxParseResponse: handleHttp2xxParseResponseDio,
          handleHttp3xxParseResponse: handleHttpGenericParseResponseDio,
          handleHttp4xxParseResponse: handleHttpGenericParseResponseDio,
          handleHttp5xxParseResponse: handleHttpGenericParseResponseDio,
          handleHttpUnknownParseResponse: handleHttpGenericParseResponseDio,
        );

    try {
      dynamic response = await apiHandler.apiCall();

      final Future<ResultState<TModel>> handleHttpResponse =
          _handleHttpResponse(
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
            'NetworkException.noInternetConnection',
            s,
          ),
        );
      }
      final ResultState<TModel> handleDioException =
          await _handleDioException(e, s);
      return handleDioException;
    } on Exception catch (e, s) {
      final FailureState<TModel> failureState =
          FailureState(DataClientExceptionState<TModel>(e.toString(), s));
      return failureState;
    }
  }

  /// _isConnected checks the current network connectivity status.
  static Future<bool> _isConnected() async {
    final ConnectivityResult result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// _handleHttpResponse processes the HTTP response and handles different
  /// status codes.
  Future<ResultState<TModel>> _handleHttpResponse<TModel>(
    ResponseParser<Response, TModel> responseParser,
  ) async {
    final int? statusCode = responseParser.response.statusCode;

    return await _handleStatusCode(statusCode, responseParser);
  }

  Future<ResultState<TModel>> _handleStatusCode<TModel>(
    int? statusCode,
    ResponseParser<Response, TModel> responseParser,
  ) async {
    return switch (statusCode) {
      final int statusCode when statusCode.isInformationHttpStatusCode =>
        await handleParseResponse_.handleHttp1xxParseResponse!(
          statusCode,
          responseParser,
        ),
      final int statusCode when statusCode.isSuccessfulHttpStatusCode =>
        await handleHttp2xxParseResponseDio<TModel>(responseParser),
      // final int statusCode when statusCode.isSuccessfulHttpStatusCode =>
      //   await handleParseResponse_.handleHttp2xxParseResponse!(responseParser),
      final int statusCode when statusCode.isRedirectHttpStatusCode =>
        await handleParseResponse_.handleHttp3xxParseResponse!(
          statusCode,
          responseParser,
        ),
      final int statusCode when statusCode.isClientErrorHttpStatusCode =>
        await handleParseResponse_.handleHttp4xxParseResponse!(
          statusCode,
          responseParser,
        ),
      final int statusCode when statusCode.isServerErrorHttpStatusCode =>
        await handleParseResponse_.handleHttp5xxParseResponse!(
          statusCode,
          responseParser,
        ),
      _ => await handleParseResponse_.handleHttpUnknownParseResponse!(
          statusCode ?? 000,
          responseParser,
        ),
    };
  }

  /// _handleDioException handles exceptions from the Dio library,
  /// particularly around connectivity.
  Future<ResultState<TModel>> _handleDioException<TModel>(
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

    late final Future<ResultState<TModel>> handleStatusCode = _handleStatusCode(
      statusCode,
      ResponseParser(
        response: Response(requestOptions: RequestOptions()),
        // coverage:ignore-start
        parserModel: (_) => Object() as TModel,
        // coverage:ignore-end
        exception: e,
        stackTrace: s,
      ),
    );

    if (statusCode != null) {
      return await handleStatusCode;
    } else {
      return switch (e.type) {
        DioExceptionType.connectionTimeout => FailureState(
            DataNetworkExceptionState<TModel>(
              'NetworkException.timeOutException',
              s,
            ),
          ),
        DioExceptionType.receiveTimeout => FailureState(
            DataNetworkExceptionState<TModel>(
              'NetworkException.receiveTimeout',
              s,
            ),
          ),
        DioExceptionType.cancel => FailureState(
            DataNetworkExceptionState<TModel>(
              'NetworkException.cancel',
              s,
            ),
          ),
        DioExceptionType.sendTimeout => FailureState(
            DataNetworkExceptionState<TModel>(
              'NetworkException.sendTimeout',
              s,
            ),
          ),
        _ => await handleStatusCode,
      };
    }
  }
}

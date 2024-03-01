import 'package:dio/dio.dart';

import '../../../exception_handler.dart';

/// An extension on `Future<Response>` providing methods for handling Dio HTTP responses and converting them
/// into [ResultState<TModel>] or [ResultState<List<TModel>>] types.
extension HttpResponseDioExtension on Future<Response> {
  /// Converts a Dio HTTP response into an [ResultState<TModel>] type using
  /// a custom `fromJson` method.
  ///
  /// Usage:
  /// ```dart
  /// final httpClient = Dio(
  ///   BaseOptions(
  ///     baseUrl: 'https://example.com/api',
  ///   ),
  /// );
  ///
  /// final yourModelOrFailure =
  ///   await httpClient.get('/data/1').fromJson(YourModel.fromJson);
  ///
  ///
  /// switch (yourModelOrFailure) {
  ///   case SuccessState<YourModel> success:
  ///     print(success.data);
  ///   case FailureState<YourModel> failure:
  ///     print(failure.exception);
  /// }
  /// ```
  ///
  /// Full example:
  /// ```dart
  /// import 'package:dio/dio.dart';
  /// import 'package:exception_handler/exception_handler.dart';
  ///
  /// class UserModel {
  ///   final int id;
  ///   final String name;
  ///   final String username;
  ///   final String email;
  ///
  ///   const UserModel({
  ///     required this.id,
  ///     required this.name,
  ///     required this.username,
  ///     required this.email,
  ///   });
  ///
  ///   factory UserModel.fromJson(Map<String, dynamic> json) {
  ///     return UserModel(
  ///       id: json["id"] as int,
  ///       name: json["name"] as String,
  ///       username: json["username"] as String,
  ///       email: json["email"] as String,
  ///     );
  ///   }
  ///
  /// @override
  /// String toString() =>
  /// '''🟩UserModel
  /// userId $id
  /// name: $name
  /// username: $username
  /// email:$email
  /// ''';
  /// }
  ///
  /// void main() async {
  ///   final httpClient = Dio(
  ///     BaseOptions(
  ///       baseUrl: 'https://jsonplaceholder.typicode.com',
  ///     ),
  ///   );
  ///
  ///   final userModelOrFailure = await httpClient.get('/users/1').fromJson(UserModel.fromJson);
  ///
  ///    switch (userModelOrFailure) {
  ///      case SuccessState<UserModel> success:
  ///        print(success.data);
  ///      case FailureState<UserModel> failure:
  ///        print(failure.exception);
  ///    }
  /// ```
  Future<ResultState<TModel>> fromJson<TModel>(
    TModel Function(Map<String, dynamic>) fromJson,
  ) async {
    final ResultState<TModel> result =
        await DioExceptionHandler().callApi<Response, TModel>(
      ApiHandler(
        apiCall: () => this, // response = dio.get('https://')
        parserModel: (Object? data) {
          final TModel resultMapper = fromJson(data as Map<String, dynamic>);
          return resultMapper;
        },
      ),
    );

    return result;
  }

  /// Converts a Dio HTTP response into an [ResultState<List<TModel>>] type
  /// using a custom `fromJsonAsList` method.
  ///
  /// Usage:
  /// ```dart
  /// final httpClient = Dio(
  ///   BaseOptions(
  ///     baseUrl: 'https://example.com/api',
  ///   ),
  /// );
  ///
  /// final yourModelsListOrFailure =
  ///   await httpClient.get('/data').fromJsonAsList(YourModel.fromJson);
  ///
  /// switch (yourModelsListOrFailure) {
  ///   case SuccessState<List<UserModel>> success:
  ///     print(success.data);
  ///   case FailureState<List<UserModel>> failure:
  ///     print(failure.exception);
  /// }
  /// ```
  ///
  /// Full example:
  /// ```dart
  /// import 'package:dio/dio.dart';
  /// import 'package:exception_handler/exception_handler.dart';
  ///
  /// class UserModel {
  ///   final int id;
  ///   final String name;
  ///   final String username;
  ///   final String email;
  ///
  ///   const UserModel({
  ///     required this.id,
  ///     required this.name,
  ///     required this.username,
  ///     required this.email,
  ///   });
  ///
  ///   factory UserModel.fromJson(Map<String, dynamic> json) {
  ///     return UserModel(
  ///       id: json["id"] as int,
  ///       name: json["name"] as String,
  ///       username: json["username"] as String,
  ///       email: json["email"] as String,
  ///     );
  ///   }
  ///
  /// @override
  /// String toString() =>
  /// '''🟩UserModel
  /// userId $id
  /// name: $name
  /// username: $username
  /// email:$email
  /// ''';
  /// }
  ///
  /// void main() async {
  ///   final httpClient = Dio(
  ///     BaseOptions(
  ///       baseUrl: 'https://jsonplaceholder.typicode.com',
  ///     ),
  ///   );
  ///
  ///   final userModelsListOrFailure =
  ///     await httpClient.get('/users').fromJsonAsList(UserModel.fromJson);
  ///
  ///    switch (userModelsListOrFailure) {
  ///      case SuccessState<List<UserModel>> success:
  ///        print(success.data);
  ///      case FailureState<List<UserModel>> failure:
  ///        print(failure.exception);
  ///    }
  /// ```
  Future<ResultState<List<TModel>>> fromJsonAsList<TModel>(
    TModel Function(Map<String, dynamic>) fromJson,
  ) async {
    final ResultState<List<TModel>> result =
        await DioExceptionHandler().callApi<Response, List<TModel>>(
      ApiHandler(
        apiCall: () => this, // response = dio.get('https://')
        parserModel: (Object? data) {
          final List<dynamic> responseData = data as List;
          final List<TModel> listResult =
              responseData.map((item) => fromJson(item)).toList();
          return listResult;
        },
      ),
    );

    return result;
  }
}

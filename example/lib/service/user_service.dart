import 'package:dio/dio.dart';
import 'package:example/model/user_model.dart';
import 'package:exception_handler/exception_handler.dart';

class UserService {
  Future<ResultState<UserModel>> getDataUser(int id) async {
    final Dio dio = Dio();

    final ResultState<UserModel> result =
        await DioExceptionHandler().callApi<Response, UserModel>(
      ApiHandler(
        apiCall: () {
          return dio.get('https://jsonplaceholder.typicode.com/users/$id');
        },
        parserModel: (Object? data) =>
            UserModel.fromJson(data as Map<String, dynamic>),
      ),
    );
    return result;
  }
}

import 'package:dio/dio.dart';
import 'package:example/model/user_model.dart';
import 'package:exception_handler/exception_handler.dart';

class UserService {
  Future<TaskResult<UserModel>> getDataUser(int id) async {
    final Dio dio = Dio();

    final TaskResult<UserModel> result =
        await DioExceptionHandler().callApi<UserModel>(
      ApiHandler(
        call: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () => dio.get('https://jsonplaceholder.typicode.com/users/$id'),
          );
        },
        parserModel: (Object? data) =>
            UserModel.fromJson(data as Map<String, dynamic>),
      ),
    );
    return result;
  }
}

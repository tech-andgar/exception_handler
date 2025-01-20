import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:exception_handler/src/src.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockConnectivity extends Mock implements Connectivity {}

class MockDioException extends Mock implements DioException {
  MockDioException({required this.type});

  @override
  DioExceptionType type;
}

class MockApiHandler<R, T> extends Mock implements ApiHandler<R, T> {}

class UserModel {
  const UserModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.phone,
    this.website,
  });

  factory UserModel.fromJson(final Map<String, dynamic> json) {
    if (json
        case {
          'id': final int? id,
          'name': final String? name,
          'username': final String? username,
          'email': final String? email,
          'phone': final String? phone,
          'website': final String? website,
        }) {
      return UserModel(
        id: id,
        name: name,
        username: username,
        email: email,
        phone: phone,
        website: website,
      );
    } else {
      throw FormatException('Invalid JSON: $json');
    }
  }

  final String? email;
  final int? id;
  final String? name;
  final String? phone;
  final String? username;
  final String? website;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['phone'] = phone;
    data['website'] = website;

    return data;
  }
}

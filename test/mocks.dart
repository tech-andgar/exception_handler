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

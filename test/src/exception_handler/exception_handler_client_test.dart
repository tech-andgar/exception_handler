import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks.dart';

void main() {
  test('Testing ClientExceptionHandler.callApi', () async {
    try {
      // Act
      await ClientExceptionHandler.callApi(
        MockApiHandler<Response<Object>, UserModel>(),
      );
    } catch (e) {
      // Assert
      expect(e, isA<UnimplementedError>());
    }
  });
}

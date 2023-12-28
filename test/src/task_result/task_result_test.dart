import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuccessState', () {
    const data = 'Test Data';
    const resultState = SuccessState<String>(data);
    test('should call success callback with correct data', () {
      final result = resultState.when(
        success: (resultData) => resultData,
        failure: (_) => 'Failure',
      );

      expect(result, equals(data));
    });
    test('should correct toString', () {
      expect(resultState.toString(), 'SuccessState<String>(data: "Test Data")');
    });
  });

  group('FailureState', () {
    final Exception exception = Exception('Test Exception');
    final FailureState<String> resultState = FailureState<String>(
      DataClientException(exception, StackTrace.current),
    );
    test('should call failure callback with correct exception', () {
      final failureCalled = resultState.when(
        success: (_) => false,
        failure: (ex) {
          expect(ex.clientException, equals(exception));
          return true;
        },
      );

      expect(failureCalled, isTrue);
    });
    test('should correct toString', () {
      expect(
        resultState.toString(),
        'FailureState<String>(exception: DataClientException<String>(clientException: Exception: Test Exception))',
      );
    });
  });
}

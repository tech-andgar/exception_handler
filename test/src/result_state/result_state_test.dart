import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuccessState', () {
    const data = 'Test Data';
    const resultState = SuccessState<String>(data);
    test('should call success callback with correct data', () {
      final result = switch (resultState) {
        FailureState<String>() => 'Failure',
        SuccessState<String>(:final String data) => data,
      };

      expect(result, equals(data));
    });
    test('should correct toString', () {
      expect(resultState.toString(), 'SuccessState<String>(data: "Test Data")');
    });
  });

  group('FailureState', () {
    final DataClientExceptionState<String> exception =
        DataClientExceptionState<String>('Test Exception', StackTrace.current);
    final FailureState<String> resultState = FailureState<String>(exception);
    test('should call failure callback with correct exception', () {
      final bool failureCalled = switch (resultState) {
        SuccessState() => false,
        FailureState() => true,
      };

      expect(failureCalled, isTrue);
      expect(resultState.exception, equals(exception));
    });
    test('should correct toString', () {
      expect(
        resultState.toString(),
        'FailureState<String>(exception: DataClientExceptionState<String>(clientException: "Test Exception"))',
      );
    });
  });
}

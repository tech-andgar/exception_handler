import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Ok',
    () {
      const data = 'Test Data';
      const resultState = Ok<String>(data);
      test('should call success callback with correct data', () {
        final result = switch (resultState) {
          Ok<String>(:final String value) => value,
        };

        expect(result, equals(data));
      });
      test('should correct toString', () {
        expect(
          resultState.toString(),
          'Ok<String>(value: "Test Data")',
        );
      });
    },
  );

  group(
    'Error',
    () {
      final DataClientExceptionState<String> exception =
          DataClientExceptionState<String>(
        message: 'Test Exception',
        stackTrace: StackTrace.current,
      );
      final Error<String> resultState = Error<String>(exception);
      test('should call failure callback with correct exception', () {
        final bool failureCalled = switch (resultState) {
          Error() => true,
        };

        expect(failureCalled, isTrue);
        expect(resultState.error, equals(exception));
      });
      test('should correct toString', () {
        expect(
          resultState.toString(),
          'Error<String>(error: DataClientExceptionState<String>(clientException: "Test Exception"))',
        );
      });
    },
  );
}

import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntExtension.isBetween', () {
    test('should return true if the number is within the range', () {
      expect(5.isBetween(3, 7), isTrue);
    });

    test(
        'should return true if the number is at the lower boundary of the range',
        () {
      expect(3.isBetween(3, 7), isTrue);
    });

    test(
        'should return true if the number is at the upper boundary of the range',
        () {
      expect(7.isBetween(3, 7), isTrue);
    });

    test('should return false if the number is below the range', () {
      expect(2.isBetween(3, 7), isFalse);
    });

    test('should return false if the number is above the range', () {
      expect(8.isBetween(3, 7), isFalse);
    });
  });
}

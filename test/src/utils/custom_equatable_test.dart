import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

class TestClass extends CustomEquatable {
  final String name;
  final int? age;
  final double? height;

  const TestClass({required this.name, this.age, this.height});

  @override
  Map<String, Object?> get namedProps =>
      {'name': name, 'age': age, 'height': height};
}

void main() {
  group('CustomEquatable Tests', () {
    test('toString should return correct format', () {
      var instance = const TestClass(name: 'John Doe', age: 30, height: 1.5);
      var expectedString = 'TestClass(name: "John Doe", age: 30, height: 1.5)';
      expect(instance.toString(), equals(expectedString));
    });
    test('toString should return correct format null', () {
      var instance = const TestClass(name: 'John Doe');
      var expectedString =
          'TestClass(name: "John Doe", age: null, height: null)';
      expect(instance.toString(), equals(expectedString));
    });

    test('Equatable properties should work correctly', () {
      var instance1 = const TestClass(name: 'John', age: 25);
      var instance2 = const TestClass(name: 'John', age: 25);
      var instance3 = const TestClass(name: 'Jane', age: 30);

      expect(instance1, equals(instance2));
      expect(instance1, isNot(equals(instance3)));
    });
  });
}

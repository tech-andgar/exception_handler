// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

import '../exception_state/exception_state.dart';

/// An abstract base class that extends [Equatable] to provide custom equality comparison
/// and string representation for objects.
///
/// This class simplifies the implementation of equatable objects by automatically
/// handling property comparison and string formatting based on named properties.
///
/// ## Usage
/// ```dart
/// class Person extends CustomEquatable {
///   final String name;
///   final int age;
///
///   const Person({required this.name, required this.age});
///
///   @override
///   Map<String, Object?> get namedProps => {
///     'name': name,
///     'age': age,
///   };
/// }
/// ```
///
/// The class provides:
/// * Automatic equality comparison through [props]
/// * Formatted string representation through [toString]
/// * Type-aware property formatting
///
/// ## Properties
/// * [props] - Returns a list of object properties for equality comparison
/// * [namedProps] - Abstract getter that must be implemented by subclasses to provide
///   a map of property names and values
///
/// ## Methods
/// * [toString] - Provides a formatted string representation of the object
/// * [_formatProperty] - Internal method to format individual properties based on their type
///
/// Note: Special handling is provided for numeric types, exceptions, enums, and custom
/// exception types (DataException, ExceptionState) to format them without quotes.
abstract class CustomEquatable extends Equatable {
  const CustomEquatable();

  @override
  List<Object?> get props => namedProps.values.toList();

  @override
  String toString() {
    final type = runtimeType.toString();
    final propList = namedProps.entries
        .map(_formatProperty)
        .where((final s) => s.isNotEmpty)
        .join(', ');

    return '$type($propList)'.replaceAll('], )', '])');
  }

  /// Formats a single property entry based on its type and value
  String _formatProperty(final MapEntry<String, Object?> entry) {
    final key = entry.key;
    final value = entry.value;

    if (value == null) {
      return '$key: null';
    }

    // Handle special types that don't need quotes
    if (value is num ||
        value is Exception ||
        value is Enum ||
        // For internal exception handler.
        value is DataException ||
        value is ExceptionState) {
      return '$key: $value';
    }

    // All other non-null values get quoted
    return '$key: "$value"';
  }

  Map<String, Object?> get namedProps;
}

// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

import '../exception_state/exceptions_state.dart';

abstract class CustomEquatable extends Equatable {
  const CustomEquatable();

  @override
  List<Object?> get props => namedProps.values.toList();

  @override
  String toString() {
    final String type = runtimeType.toString();
    final String propList = namedProps.entries
        .map(
          (MapEntry<String, Object?> e) => (e.value is num ||
                  e.value is Exception ||
                  e.value is Enum ||
                  e.value
                      is ExceptionState || // For internal exception handler.
                  e.value == null)
              ? '${e.key}: ${e.value}'
              : '${e.key}: "${e.value}"',
        )
        .join(', ');

    return '$type($propList)';
  }

  Map<String, Object?> get namedProps;
}

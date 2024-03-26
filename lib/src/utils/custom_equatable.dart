// Copyright (c) 2024, TECH-ANDGAR.
// All rights reserved. Use of this source code
// is governed by a Apache-2.0 license that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

import '../exception_state/exception_state.dart';

abstract class CustomEquatable extends Equatable {
  const CustomEquatable();

  @override
  List<Object?> get props => namedProps.values.toList();

  @override
  String toString() {
    final String type = runtimeType.toString();
    final String propList = namedProps.entries
        .map(
          (final MapEntry<String, Object?> e) => (e.value is num ||
                  e.value is Exception ||
                  e.value is Enum ||
                  // For internal exception handler.
                  e.value is ExceptionState ||
                  e.value == null)
              ? '${e.key}: ${e.value}'
              : e.value != null && e.value != ''
                  ? '${e.key}: "${e.value}"'
                  : '',
        )
        .join(', ');

    return '$type($propList)'.replaceAll('], )', '])');
  }

  Map<String, Object?> get namedProps;
}

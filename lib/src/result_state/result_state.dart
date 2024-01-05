import '../exception_state/exceptions_state.dart';
import '../utils/utils.dart';

/// An sealed base class to represent the different states of result.
sealed class ResultState<T> extends CustomEquatable {
  const ResultState();
}

/// Success status with a generic value T.
class SuccessState<T> extends ResultState<T> {
  const SuccessState(this.data);

  final T data;

  @override
  Map<String, Object?> get namedProps => {'data': data};
}

/// Error status with a specific type of exception.
class FailureState<T> extends ResultState<T> {
  const FailureState(this.exception);

  final ExceptionState<T> exception;

  @override
  Map<String, Object?> get namedProps => {'exception': exception};
}

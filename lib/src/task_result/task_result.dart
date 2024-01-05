import '../exception_state/exceptions_state.dart';
import '../utils/utils.dart';

/// An sealed base class to represent the different states of task result.
sealed class TaskResult<T> extends CustomEquatable {
  const TaskResult();
}

/// Success status with a generic value T.
class SuccessState<T> extends TaskResult<T> {
  const SuccessState(this.data);

  final T data;

  @override
  Map<String, Object?> get namedProps => {'data': data};
}

/// Error status with a specific type of exception.
class FailureState<T> extends TaskResult<T> {
  const FailureState(this.exception);

  final ExceptionState<T> exception;

  @override
  Map<String, Object?> get namedProps => {'exception': exception};
}

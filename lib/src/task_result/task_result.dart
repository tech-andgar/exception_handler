import '../utils/utils.dart';
import '../exception_state/exceptions_state.dart';

/// An abstract base class to represent the different states of task result.
abstract class TaskResult<T> extends CustomEquatable {
  const TaskResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(ExceptionState<T> exception) failure,
  });
}

/// Success status with a generic value T.
class SuccessState<T> extends TaskResult<T> {
  const SuccessState(this.data);

  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(ExceptionState<T> exception) failure,
  }) =>
      success(data);

  @override
  Map<String, Object?> get namedProps => {'data': data};
}

/// Error status with a specific type of exception.
class FailureState<T> extends TaskResult<T> {
  const FailureState(this.exception);

  final ExceptionState<T> exception;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(ExceptionState<T> exception) failure,
  }) =>
      failure(exception);

  @override
  Map<String, Object?> get namedProps => {'exception': exception};
}

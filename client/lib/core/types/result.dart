import 'failure.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

class FailureResult<T> extends Result<T> {
  final Failure failure;

  const FailureResult(this.failure);
}

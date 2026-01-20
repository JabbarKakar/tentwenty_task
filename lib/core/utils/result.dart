/// A result type that represents either success or failure
///
///
import '../errors/failures.dart';
sealed class Result<T> {
  const Result();
}

/// Success result containing data
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result containing error
final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}



/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Returns true if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is an error
  bool get isError => this is Error<T>;

  /// Returns the data if success, null otherwise
  T? get dataOrNull => switch (this) {
        Success(data: final data) => data,
        Error() => null,
      };

  /// Returns the failure if error, null otherwise
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(failure: final failure) => failure,
      };

  /// Pattern matching for Result
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Error(failure: final failure) => error(failure),
    };
  }
}

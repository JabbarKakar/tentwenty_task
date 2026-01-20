/// Base class for all failures
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

/// Server/API related failures
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, [this.statusCode]);
}

/// Data parsing failures
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse data']);
}

/// Null/Empty data failures
class NullFailure extends Failure {
  const NullFailure([super.message = 'Data is null or empty']);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}

/// No internet connection failure
class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = 'No internet connection']);
}

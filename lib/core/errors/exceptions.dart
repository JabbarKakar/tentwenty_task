/// Base class for all exceptions
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed']);
}

/// Server/API related exceptions
class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, [this.statusCode]);
}

/// Data parsing exceptions
class ParsingException extends AppException {
  const ParsingException([super.message = 'Failed to parse data']);
}

/// Null/Empty data exceptions
class NullException extends AppException {
  const NullException([super.message = 'Data is null or empty']);
}

/// Timeout exceptions
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timeout']);
}

/// No internet connection exception
class NoInternetException extends AppException {
  const NoInternetException([super.message = 'No internet connection']);
}

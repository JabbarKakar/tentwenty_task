import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Dio client configuration for API calls
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Handle Dio errors and convert to custom exceptions
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutException('Request timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['status_message'] as String? ??
            error.message ??
            'Server error occurred';
        throw ServerException(message, statusCode);
      case DioExceptionType.cancel:
        throw const NetworkException('Request was cancelled');
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Failed host lookup') == true) {
          throw const NoInternetException();
        }
        throw NetworkException(error.message ?? 'Network error occurred');
      case DioExceptionType.badCertificate:
        throw const NetworkException('Bad certificate');
      case DioExceptionType.connectionError:
        throw const NoInternetException();
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}

/// Unknown exception class
class UnknownException extends AppException {
  UnknownException([super.message = 'An unknown error occurred']);
}

import 'package:dio/dio.dart';

enum AppExceptionType { network, server, auth, unknown }

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final AppExceptionType type;

  const AppException({
    required this.message,
    this.statusCode,
    this.type = AppExceptionType.unknown,
  });

  @override
  String toString() => 'AppException($type): $message';
}

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  Future<T> get<T>(String path, {Map<String, dynamic>? params}) async {
    try {
      final res = await _dio.get<T>(path, queryParameters: params);
      return res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    try {
      final res = await _dio.post<T>(path, data: data);
      return res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> put<T>(String path, {dynamic data}) async {
    try {
      final res = await _dio.put<T>(path, data: data);
      return res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const AppException(
          message: 'No internet connection. Please check your network.',
          type: AppExceptionType.network,
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          return AppException(
            message: 'Session expired. Please log in again.',
            statusCode: code,
            type: AppExceptionType.auth,
          );
        }
        return AppException(
          message: e.response?.data?['message'] as String? ?? 'Server error.',
          statusCode: code,
          type: AppExceptionType.server,
        );
      default:
        return AppException(
          message: e.message ?? 'An unexpected error occurred.',
          type: AppExceptionType.unknown,
        );
    }
  }
}

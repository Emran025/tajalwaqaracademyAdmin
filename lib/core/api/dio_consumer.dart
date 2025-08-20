import 'package:dio/dio.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'api_consumer.dart';

/// The concrete implementation of the [ApiConsumer] contract using the Dio library.
///
/// This class acts as the primary data-layer gateway to the network. Its sole
/// responsibility is to execute HTTP requests using a pre-configured Dio instance
/// and to translate low-level [DioException]s into application-specific
/// [ServerException]s.
///
/// By receiving a fully configured [Dio] instance via dependency injection, this
/// class remains decoupled from the complexities of network setup, such as
/// interceptor logic, base URLs, or timeouts. This enhances testability and
/// adheres to the Single Responsibility Principle.
final class DioConsumer implements ApiConsumer {
  /// The pre-configured Dio instance for all network operations.
  final Dio _dio;

  /// Constructs a [DioConsumer].
  ///
  /// The [dio] instance provided should be fully configured and supplied by
  /// a dependency injection container.
  DioConsumer({required Dio dio}) : _dio = dio;

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      // Translate a Dio-specific error into an application-specific exception.
       handleDioExceptions(e);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: isFormData ? FormData.fromMap(data as Map<String, dynamic>) : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
       handleDioExceptions(e);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: isFormData ? FormData.fromMap(data as Map<String, dynamic>) : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
       handleDioExceptions(e);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: isFormData ? FormData.fromMap(data as Map<String, dynamic>) : data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
       handleDioExceptions(e);
    }
  }
}
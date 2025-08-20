import 'package:dio/dio.dart';

import 'failures.dart';


// lib/core/error/exceptions.dart

/// A base class for all custom exceptions in the application.
///
/// Implementing [Exception] allows these classes to be thrown and caught
/// as exceptions. This is the technical layer representation of an error,
/// which will be caught in the data layer (Repository) and converted into
/// a domain-layer `Failure`.
abstract class AppException implements Exception {
  final String message;
  final String? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => 'AppException: $message (Code: $statusCode)';
}

/// Thrown when an error occurs during an API request.
///
/// This exception is typically thrown from a remote data source when an HTTP
/// request fails (e.g., status code 4xx or 5xx).
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});

  @override
  String toString() => 'ServerException: $message (Code: $statusCode)';
}

/// Thrown when there is an issue with the network connection.
///
/// This can be used to wrap Dart's `SocketException` or other network-related
/// errors into a more specific application exception.
class NetworkException extends AppException {
  const NetworkException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'NetworkException: $message';
}


/// Thrown when an error occurs while accessing local cache or database.
///
/// For example, if the database is not found, a table is missing, or
/// a query returns no results when one was expected.
class CacheException extends AppException {
  const CacheException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when data parsing (e.g., from JSON) fails.
///
/// This can be used to wrap `FormatException` or other errors that occur
/// when trying to convert raw data into data models.
class DataParsingException extends AppException {
  const DataParsingException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'DataParsingException: $message';
}

/// Thrown for any other unexpected error.
///
/// This serves as a generic fallback for exceptions that don't fit into
/// the other more specific categories.
class UnknownException extends AppException {
  const UnknownException({required super.message}) : super(statusCode: null);

  @override
  String toString() => 'UnknownException: $message';
}

void handleDioExceptions(DioException? e) {
  if (e != null) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,
        );
      case DioExceptionType.sendTimeout:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,        );
      case DioExceptionType.receiveTimeout:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,        );
      case DioExceptionType.badCertificate:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,        );
      case DioExceptionType.cancel:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,        );
      case DioExceptionType.connectionError:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,        );
      case DioExceptionType.unknown:
        throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: ErrorModel.fromJson(e.response!.data).status,        );
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400: // Bad request
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",
          );
          case 401: //unauthorized
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",         );
          case 403: //forbidden
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",             );
          case 404: //not found
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",            );
          case 409: //cofficient
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",          );
          case 422: //  Unprocessable Entity
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",            );
          case 504: // Server exception
            throw ServerException(
          message: ErrorModel.fromJson(e.response!.data).message,
          statusCode: "${e.response?.statusCode}",            );
        }
    }
  } else {
    throw ServerException(
      
        message: "There is No Internet check it ...",
        statusCode: "400",
      
    );
  }
}


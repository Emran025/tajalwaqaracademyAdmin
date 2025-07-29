import 'package:dio/dio.dart';

import 'error_model.dart';

/// يُرمى لما يفشل الوصول أو التخزين في الكاش/قاعدة البيانات
class CacheException implements Exception {
    final String message;

  CacheException({required this.message});
}

class ServerException implements Exception {
  final ErrorModel errorModel;

  ServerException({required this.errorModel});
}

void handleDioExceptions(DioException? e) {
  if (e != null) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.sendTimeout:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.receiveTimeout:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.badCertificate:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.cancel:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.connectionError:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.unknown:
        throw ServerException(
          errorModel: ErrorModel.fromJson(e.response!.data),
        );
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400: // Bad request
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
          case 401: //unauthorized
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
          case 403: //forbidden
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
          case 404: //not found
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
          case 409: //cofficient
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
          case 422: //  Unprocessable Entity
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
          case 504: // Server exception
            throw ServerException(
              errorModel: ErrorModel.fromJson(e.response!.data),
            );
        }
    }
  } else {
    throw ServerException(
      errorModel: ErrorModel(
        message: "There is No Internet check it ...",
        status: "400",
      ),
    );
  }
}

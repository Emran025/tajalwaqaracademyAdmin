
// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';
import '../api/end_ponits.dart';

class ErrorModel {
  final String status;
  final String message;

  ErrorModel({required this.status, required this.message});
  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    return ErrorModel(
      status: jsonData[ApiKey.status] ?? '',
      message: jsonData[ApiKey.message] ?? '',
    );
  }
}




abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]);

  @override
  List<Object> get props => [];
}

/// Represents a failure from the server (API).
class ServerFailure extends Failure {
  final String message;
  const ServerFailure({this.message = 'An error occurred on the server.'});
}

/// Represents a failure from the local cache (database).
class CacheFailure extends Failure {
    final String message;
  const CacheFailure({this.message = 'An error occurred in the local data source.'});
}

/// Represents a failure due to no internet connection.
class NetworkFailure extends Failure {
    final String message;
  const NetworkFailure({this.message = 'No internet connection found.'});
}
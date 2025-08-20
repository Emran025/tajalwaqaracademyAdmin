
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





/// Represents a general failure in the application.
///
/// This abstract class serves as the base for all specific types of failures
/// that can occur within the application's business logic.
/// It uses `Equatable` for easy comparison of failure objects.
abstract class Failure extends Equatable {
  // A descriptive message that can be shown to the user or logged.
  final String message;
  // An optional status code, useful for API-related failures.
  final String? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure related to data access or parsing.
///
/// This includes issues like corrupted data, malformed JSON, or problems
/// retrieving data from local storage/database.
class DataFailure extends Failure {
  const DataFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String toString() => 'DataFailure: $message (Code: $statusCode)';
}

/// Represents a failure due to network connectivity issues.
///
/// This includes cases where there's no internet connection or the server
/// is unreachable.
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String toString() => 'NetworkFailure: $message (Code: $statusCode)';
}

/// Represents a failure related to server-side issues.
///
/// This typically corresponds to HTTP errors (e.g., 404, 500) received from an API.
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String toString() => 'ServerFailure: $message (Code: $statusCode)';
}

/// Represents a failure for unexpected or unknown errors.
///
/// This is a fallback for errors that don't fit into other specific categories.
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String toString() => 'UnknownFailure: $message (Code: $statusCode)';
}

/// Represents a failure when an operation tries to access local data that does not exist.
///
/// This can be used, for instance, when attempting to read from a database
/// or cache that hasn't been initialized or contains no data for a given query.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.statusCode,
  });

  @override
  String toString() => 'CacheFailure: $message (Code: $statusCode)';
}

// You can add more specific failure types as your application grows,
// e.g., `AuthenticationFailure`, `PermissionFailure`, etc.
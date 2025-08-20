// lib/core/usecase/usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// An abstract class representing a single business logic use case.
///
/// Each use case in the application should extend this class.
/// It standardizes the execution of use cases, ensuring they all have a `call` method.
///
/// It uses a generic approach:
/// - `Type`: The return type of the use case (e.g., `List<Surah>`, `void`).
/// - `Params`: The parameters required to execute the use case.
///
/// The `call` method returns an `Either<Failure, Type>`, which is a functional
/// programming concept from the `dartz` package. This allows for explicit
/// handling of both success and failure scenarios without using traditional
/// try-catch blocks in the presentation layer.
abstract class UseCase<Type, Params> {
  /// Executes the business logic of the use case.
  ///
  /// Returns a `Future` that resolves to an `Either` type:
  /// - `Left<Failure>`: Contains a `Failure` object if the operation fails.
  /// - `Right<Type>`: Contains the successful result of type `Type`.
  Future<Either<Failure, Type>> call(Params params);
}

/// A specific parameter class for use cases that do not require any input.
///
/// This provides a clean, type-safe way to call use cases that have no parameters,
/// for example: `useCase(const NoParams())`.
/// It extends `Equatable` to allow for easy comparison.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
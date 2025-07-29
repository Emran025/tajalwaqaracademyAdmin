// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import 'package:tajalwaqaracademy/core/errors/error_model.dart';

/// A generic use case with parameters.
/// [Type] is the return type on success.
/// [Params] is the parameters type.

/// Abstract contract for use cases that return a single result via a [Future].
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Abstract contract for use cases that return a continuous stream of results.
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// A class representing no parameters for a use case.
class NoParams {}

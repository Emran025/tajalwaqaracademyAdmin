import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/features/HalaqasManagement/domain/repositories/halaqa_repository.dart';

import '../../../../core/error/failures.dart';
import 'usecase.dart';

/// A domain layer use case responsible for changing a halaqa's status.
///
/// This use case orchestrates the business logic of updating a halaqa's
/// status by delegating the data operation to the [HalaqaRepository].
@lazySingleton
class SetHalaqaStatusUseCase implements UseCase<Unit, SetHalaqaStatusParams> {
  final HalaqaRepository _repository;

  SetHalaqaStatusUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Takes [SetHalaqaStatusParams] containing the halaqa's ID and the new
  /// status, and requests the repository to perform the update.
  /// Returns [Right(unit)] on success or [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> call(SetHalaqaStatusParams params) async {
    // The use case's primary role is to delegate the call to the repository.
    // It can also contain additional business logic if needed (e.g., checking
    // user permissions before making the call).
    return await _repository.setHalaqaStatus(
      halaqaId: params.halaqaId,
      newStatus: params.newStatus,
    );
  }
}

/// Encapsulates the parameters required for the [SetHalaqaStatusUseCase].

final class SetHalaqaStatusParams {
  final String halaqaId;
  final ActiveStatus newStatus;

  const SetHalaqaStatusParams({
    required this.halaqaId,
    required this.newStatus,
  });
}

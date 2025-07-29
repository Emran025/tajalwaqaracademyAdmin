import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:tajalwaqaracademy/core/models/active_status.dart';

import '../../../../core/errors/error_model.dart';
import '../repositories/student_repository.dart';
import 'usecase.dart';

/// A domain layer use case responsible for changing a student's status.
///
/// This use case orchestrates the business logic of updating a student's
/// status by delegating the data operation to the [StudentRepository].
@lazySingleton
class SetStudentStatusUseCase implements UseCase<Unit, SetStudentStatusParams> {
  final StudentRepository _repository;

  SetStudentStatusUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Takes [SetStudentStatusParams] containing the student's ID and the new
  /// status, and requests the repository to perform the update.
  /// Returns [Right(unit)] on success or [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> call(SetStudentStatusParams params) async {
    // The use case's primary role is to delegate the call to the repository.
    // It can also contain additional business logic if needed (e.g., checking
    // user permissions before making the call).
    return await _repository.setStudentStatus(
      studentId: params.studentId,
      newStatus: params.newStatus,
    );
  }
}

/// Encapsulates the parameters required for the [SetStudentStatusUseCase].
final class SetStudentStatusParams {
  final String studentId;
  final ActiveStatus newStatus;

  const SetStudentStatusParams({
    required this.studentId,
    required this.newStatus,
  });
}

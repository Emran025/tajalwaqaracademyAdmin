import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/repositories/teacher_repository.dart';

import '../../../../core/error/failures.dart';
import 'usecase.dart';

/// A domain layer use case responsible for changing a teacher's status.
///
/// This use case orchestrates the business logic of updating a teacher's
/// status by delegating the data operation to the [TeacherRepository].
@lazySingleton
class SetTeacherStatusUseCase implements UseCase<Unit, SetTeacherStatusParams> {
  final TeacherRepository _repository;

  SetTeacherStatusUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Takes [SetTeacherStatusParams] containing the teacher's ID and the new
  /// status, and requests the repository to perform the update.
  /// Returns [Right(unit)] on success or [Left(Failure)] on error.
  @override
  Future<Either<Failure, Unit>> call(SetTeacherStatusParams params) async {
    // The use case's primary role is to delegate the call to the repository.
    // It can also contain additional business logic if needed (e.g., checking
    // user permissions before making the call).
    return await _repository.setTeacherStatus(
      teacherId: params.teacherId,
      newStatus: params.newStatus,
    );
  }
}

/// Encapsulates the parameters required for the [SetTeacherStatusUseCase].


final class SetTeacherStatusParams  {
  final String teacherId;
  final ActiveStatus newStatus;

  const SetTeacherStatusParams({
    required this.teacherId,
    required this.newStatus,
  });

}



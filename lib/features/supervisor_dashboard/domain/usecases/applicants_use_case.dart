// Applicants_use_case.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/user_role.dart';
import '../../../StudentsManagement/domain/entities/paginated_applicants_result.dart';
import '../repositories/repository.dart';

import 'package:injectable/injectable.dart';
@injectable
class GetApplicantsUseCase {
  final SupervisorRepository _repository;
  GetApplicantsUseCase(this._repository);

  Future<Either<Failure, PaginatedApplicantsResult>> call({
    int page = 1,
    required UserRole entityType,
  }) {
    return _repository.getApplicants(page: page, entityType: entityType);
  }
}

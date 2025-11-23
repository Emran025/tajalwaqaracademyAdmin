// applications_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/user_role.dart';
import '../../../StudentsManagement/domain/entities/paginated_applications_result.dart';
import '../repositories/repository.dart';


@injectable
class GetApplicationsUseCase {
  final SupervisorRepository _repository;
  GetApplicationsUseCase(this._repository);

  Future<Either<Failure, PaginatedApplicationsResult>> call({
    int page = 1, required UserRole entityType 
  }) {
    return _repository.getApplications(page: page , entityType: entityType);
  }
}
import '../../../../core/entities/pagination_info_entity.dart';
import '../../../supervisor_dashboard/domain/entities/applicant_entity.dart';

class PaginatedApplicantsResult {
  final List<ApplicantEntity> applicants;
  final PaginationInfoEntity pagination;

  PaginatedApplicantsResult({
    required this.applicants,
    required this.pagination,
  });
}

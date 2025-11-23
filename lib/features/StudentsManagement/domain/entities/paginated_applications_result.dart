
import '../../../../core/entities/pagination_info_entity.dart';
import '../../../supervisor_dashboard/domain/entities/application_entity.dart';

class PaginatedApplicationsResult {
  final List<ApplicationEntity> applications;
  final PaginationInfoEntity pagination;

  PaginatedApplicationsResult({
    required this.applications,
    required this.pagination,
  });
}
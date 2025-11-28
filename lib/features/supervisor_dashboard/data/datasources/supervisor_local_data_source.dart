// lib/features/supervisor_dashboard/data/datasources/supervisor_local_data_source.dart

import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/applicant_model.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/applicant_profile_model.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/chart_data_point.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/composite_performance_data.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/count_delta.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/halqa_statistics.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/school_statistics.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/student_summaray_record.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';

abstract class SupervisorLocalDataSource {
  Future<List<ApplicantModel>> getApplicants(
      int userId, String applicationType);
  Future<ApplicantProfileModel> getApplicantProfile(int userId, int id);
  Future<void> approveApplicant(int userId, int id);
  Future<void> rejectApplicant(int userId, int id);
  Future<SchoolStatistics> getSchoolStatistics(int userId);
  Future<HalqaStatistics> getHalqaStatistics(int userId, int halqaId);
  Future<List<StudentSummaryRecord>> getStudentSummary(int userId, int halqaId);
  Future<CompositePerformanceData> getCompositePerformanceData(
      int userId, ChartFilter filter);
  Future<List<ChartDataPoint>> getStudentsNotTracking(
      int userId, ChartFilter filter);
  Future<CountDelta> getStudentCount(int userId, ChartFilter filter);
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/repositories/student_repository.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/factories/follow_up_report_factory.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/presentation/view_models/follow_up_report_bundle_entity.dart';
// ... (imports)

@lazySingleton
class GenerateFollowUpReportUseCase
    extends UseCase<FollowUpReportBundleEntity, String> {
  final StudentRepository _repository;
  final FollowUpReportFactory _factory;

  GenerateFollowUpReportUseCase(this._repository, this._factory);

  @override
  Future<Either<Failure, FollowUpReportBundleEntity>> call(
    String studentId,
  ) async {
    print("===== USE CASE: START =====");
    print("USE CASE: Fetching plan for student ID: $studentId");
    final planResult = await _repository.getFollowUpPlan(studentId);

    print("USE CASE: Fetching trackings for student ID: $studentId");
    final trackingsResult = await _repository.getFollowUpTrackings(studentId);

    // -->> نقطة تفتيش حاسمة <<--
    // تحقق مما إذا كانت البيانات قد تم جلبها بنجاح من الـ Repository
    return planResult.fold(
      (planFailure) {
        print("USE CASE: FAILED to get plan. Reason: $planFailure");
        return Left(planFailure);
      },
      (planEntity) {
        print(
          "USE CASE: SUCCEEDED to get plan. Plan details count: ${planEntity.details.length}",
        );

        return trackingsResult.fold(
          (trackingsFailure) {
            print(
              "USE CASE: FAILED to get trackings. Reason: $trackingsFailure",
            );
            return Left(trackingsFailure);
          },
          (trackingEntities) {
            print(
              "USE CASE: SUCCEEDED to get trackings. Trackings count: ${trackingEntities.length}",
            );
            print("USE CASE: Now entering the Factory...");

            try {
              // استدعاء الـ Factory داخل try-catch صريح
              final reportBundle = _factory.create(
                plan: planEntity,
                trackings: trackingEntities,
                totalPendingReports: 2, // Example value
              );

              print("USE CASE: Factory processing COMPLETED successfully.");
              print("USE CASE: Returning Right(reportBundle).");
              // إذا وصلنا إلى هنا، فكل شيء على ما يرام
              return Right(reportBundle);
            } catch (e, stackTrace) {
              // -->> هذا هو الجزء الأهم <<--
              // إذا حدث أي خطأ داخل الـ Factory، سيتم التقاطه هنا
              print("!!!!!! USE CASE: CRITICAL ERROR INSIDE FACTORY !!!!!!");
              print("!!!!!! ERROR: $e");
              print("!!!!!! STACK TRACE: $stackTrace");
              return Left(
                CacheFailure(message: "Error during report generation: $e"),
              );
            }
          },
        );
      },
    );
  }
}

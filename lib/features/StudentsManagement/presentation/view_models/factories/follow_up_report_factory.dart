// lib/features/StudentsManagement/domain/factories/follow_up_report_factory.dart

import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/models/tracking_units.dart';
import '../planned_detail_entity.dart';
import '../actual_progress_entity.dart';
import '../../../domain/entities/follow_up_plan_entity.dart';
import '../../../domain/entities/tracking_detail_entity.dart';
import '../../../domain/entities/tracking_entity.dart';
import '../follow_up_report_bundle_entity.dart';
import '../follow_up_report_entity.dart';
import '../follow_up_report_detail_entity.dart';
import '../student_summary_entity.dart';
import '../student_performance_metrics_entity.dart';

@injectable
class FollowUpReportFactory {
  static const double _pagesPerJuz = 20.0;

  static const double _pagesPerHizb = 10.0;

  static const double _pagesPerHalfHizb = 5.0;
  static const double _pagesPerQuarterHizb = 2.5;

  static const double _behindStatusThreshold = -5.0;

  static const double _aheadStatusThreshold = 5.0;

  /// {@template follow_up_report_factory.create}

  /// [plan]و [trackings]
  /// {@endtemplate}
  FollowUpReportBundleEntity create({
    required FollowUpPlanEntity plan,
    required List<TrackingEntity> trackings,
    required int totalPendingReports,
  }) {
    final processedReports = _processDailyReports(trackings, plan);

    // الخطوة الثانية: حساب الملخص الإجمالي بناءً على التقارير المنظمة.
    final summary = _calculateSummary(processedReports, totalPendingReports);

    return FollowUpReportBundleEntity(
      followUpReports: processedReports,
      summary: summary,
    );
  }

  /// يعالج قائمة سجلات التتبع الخام ويحولها إلى قائمة تقارير يومية منظمة.
  List<FollowUpReportEntity> _processDailyReports(
    List<TrackingEntity> trackings,
    FollowUpPlanEntity plan,
  ) {
    return trackings
        .map((tracking) => _processSingleReport(tracking, plan))
        .toList();
  }

  /// يعالج سجل تتبع يومي واحد ويحوله إلى كيان تقرير منظم.
  FollowUpReportEntity _processSingleReport(
    TrackingEntity tracking,
    FollowUpPlanEntity plan,
  ) {
    // حساب تفاصيل الأداء (الحفظ، المراجعة، الخ) لهذا اليوم.
    final details = _calculateReportDetails(tracking.details, plan);

    return FollowUpReportEntity(
      id: int.parse(tracking.id),
      trackDate: tracking.date,
      attendance: tracking.details.isNotEmpty
          ? AttendanceStatus.present
          : AttendanceStatus.absent,
      behaviourAssessment: tracking.behaviorNote.toDouble(),
      details: details,
    );
  }

  /// يحسب قائمة تفاصيل الأداء ليوم واحد.
  List<FollowUpReportDetailEntity> _calculateReportDetails(
    List<TrackingDetailEntity> trackingDetails,
    FollowUpPlanEntity plan,
  ) {
    return trackingDetails
        .map((trackingDetail) {
          final planDetail = plan.details.firstWhereOrNull(
            (p) => p.type == trackingDetail.trackingTypeId,
          );
          if (planDetail == null) {
            return null;
          }

          final plannedAmount = _normalizeToCommonUnit(
            planDetail.amount,
            planDetail.unit,
          );
          final actualAmount = trackingDetail.actualAmount.toDouble();
          final gap = actualAmount - plannedAmount;

          return FollowUpReportDetailEntity(
            type: trackingDetail.trackingTypeId,
            plannedDetail: PlannedDetailEntity(
              unit: planDetail.unit,
              amount: planDetail.amount,
            ),
            actual: ActualProgressEntity(
              unit: TrackingUnit
                  .page, // يجب أن تكون الوحدة ديناميكية إذا كانت تتغير
              fromTrackingUnitId: trackingDetail.fromTrackingUnitId,
              toTrackingUnitId: trackingDetail.toTrackingUnitId,
            ),
            gap: gap,
            performanceScore: trackingDetail.score.toDouble(),
            note: trackingDetail.comment,
          );
        })
        .whereType<FollowUpReportDetailEntity>()
        .toList();
  }

  StudentSummaryEntity _calculateSummary(
    List<FollowUpReportEntity> reports,
    int totalPendingReports,
  ) {
    if (reports.isEmpty) {
      // التعامل مع حالة عدم وجود تقارير
      return StudentSummaryEntity(
        totalPendingReports: totalPendingReports,
        totalDeviation: 0,
        status: PerformanceStatus.onTrack,
        studentPerformance: const StudentPerformanceMetricsEntity(
          averageBehaviourScore: 0,
          averageAchievementRate: 0,
          averageExecutionQuality: 0,
          reportCount: 0,
        ),
      );
    }

    final totalDeviation = reports.fold<double>(
      0.0,
      (sum, report) => sum + report.details.fold(0.0, (s, d) => s + d.gap),
    );
    final totalBehaviourScore = reports.fold<double>(
      0.0,
      (sum, report) => sum + report.behaviourAssessment,
    );
    final avgBehaviour = totalBehaviourScore / reports.length;
    final allDetails = reports.expand((report) => report.details).toList();
    final totalExecutionQuality = allDetails.fold<double>(
      0.0,
      (sum, detail) => sum + detail.performanceScore,
    );

    double totalAchievementRate = 0;
    for (var detail in allDetails) {
      final plannedAmount = _normalizeToCommonUnit(
        detail.plannedDetail.amount,
        detail.plannedDetail.unit,
      );
      final actualAmount =
          _normalizeToCommonUnit(
            detail.actual.fromTrackingUnitId.toPage -
                detail.actual.fromTrackingUnitId.fromPage,
            TrackingUnit.fromId(detail.actual.fromTrackingUnitId.unitId),
          ) +
          _normalizeToCommonUnit(
            detail.actual.toTrackingUnitId.toPage -
                detail.actual.toTrackingUnitId.fromPage,
            TrackingUnit.fromId(detail.actual.toTrackingUnitId.unitId),
          ); // افتراض
      if (plannedAmount > 0) {
        totalAchievementRate += (actualAmount / plannedAmount) * 100;
      } else if (actualAmount > 0) {
        totalAchievementRate += 100.0;
      }
    }

    final avgExecutionQuality = allDetails.isNotEmpty
        ? totalExecutionQuality / allDetails.length
        : 0.0;
    final avgAchievement = allDetails.isNotEmpty
        ? totalAchievementRate / allDetails.length
        : 0.0;

    return StudentSummaryEntity(
      totalPendingReports: totalPendingReports,
      totalDeviation: totalDeviation,
      status: _getPerformanceStatus(totalDeviation),
      studentPerformance: StudentPerformanceMetricsEntity(
        averageBehaviourScore: avgBehaviour,
        averageAchievementRate: avgAchievement,
        averageExecutionQuality: avgExecutionQuality,
        reportCount: reports.length,
      ),
    );
  }

  double _normalizeToCommonUnit(num amount, TrackingUnit unit) {
    switch (unit) {
      case TrackingUnit.hizb:
        return amount * _pagesPerHizb;
      case TrackingUnit.juz:
        return amount * _pagesPerJuz;
      case TrackingUnit.halfHizb:
        return amount * _pagesPerHalfHizb;
      case TrackingUnit.quarterHizb:
        return amount * _pagesPerQuarterHizb;
      default:
        return amount.toDouble();
    }
  }

  PerformanceStatus _getPerformanceStatus(double deviation) {
    if (deviation < _behindStatusThreshold) {
      return PerformanceStatus.behind;
    } else if (deviation > _aheadStatusThreshold) {
      return PerformanceStatus.ahead;
    }
    return PerformanceStatus.onTrack;
  }
}

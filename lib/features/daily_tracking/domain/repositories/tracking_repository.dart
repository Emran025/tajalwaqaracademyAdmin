import 'package:dartz/dartz.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';

// Import the pure domain entities
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_detail_entity.dart';

import '../entities/mistake.dart';

/// Abstract contract for the tracking repository.
///
/// This defines the high-level data operations for the interactive tracking feature.
/// It acts as the bridge between the domain layer (UseCases) and the data layer
/// (DataSources), working exclusively with domain entities.
abstract class TrackingRepository {
  /// Gets the DRAFT tracking details for a given student's enrollment for the current date.
  ///
  /// If no draft entry exists for today, the data layer is responsible for creating a new one,
  /// intelligently setting its starting point based on the last completed session.
  ///
  /// Returns a [Right] containing a map where the key is the `TrackingType` and the
  /// value is the corresponding `TrackingDetailEntity`.
  /// Returns a [Left] with a `Failure` on error.
  Future<Either<Failure, Map<TrackingType, TrackingDetailEntity>>>
  getOrCreateTodayDraftTrackingDetails({
    required String enrollmentId, // Using String as agreed
  });

  /// Saves the current "draft" state of a tracking task.
  ///
  /// This is used for autosaving the session. It persists the `TrackingDetailEntity`,
  /// including its list of mistakes, to the local database and.
  ///
  /// Returns a [Right] with `unit` on success, or a [Left] with a `Failure` on error.
  Future<Either<Failure, Unit>> saveDraftTaskProgress(
    TrackingDetailEntity detail,
  );

  /// Finalizes the daily tracking session.
  ///
  /// This operation updates the status of the tracking record from 'draft' to 'completed'
  /// in the local database and queues this final update for synchronization.
  ///
  /// Returns a [Right] with `unit` on success, or a [Left] with a `Failure` on error.
  Future<Either<Failure, Unit>> finalizeSession({
    required int trackingId, // The local ID of the parent daily_tracking record
    required String finalNotes,
    required int behaviorScore,
  });

  ///
  ///

  Future<Either<Failure, List<Mistake>>> getAllMistakes({
    required String enrollmentId,
    TrackingType? type, // <-- NOW OPTIONAL
    int? fromPage,
    int? toPage,
  });

  Future<Either<Failure, List<BarChartDatas>>> getErrorAnalysisChartData({
    required String enrollmentId,
    required ChartFilter filter,
  });
}

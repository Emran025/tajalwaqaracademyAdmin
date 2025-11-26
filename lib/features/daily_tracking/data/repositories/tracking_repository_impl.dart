import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/exceptions.dart';
import 'package:tajalwaqaracademy/core/models/tracking_type.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/data/models/bar_chart_datas.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';

// Domain Layer imports
import '../../../../core/error/failures.dart';
import '../../../StudentsManagement/data/models/tracking_detail_model.dart';
import '../../../StudentsManagement/domain/entities/tracking_detail_entity.dart';
import '../../domain/entities/mistake.dart';
import '../../domain/repositories/tracking_repository.dart';

// Data Layer imports
import '../datasources/tracking_local_data_source.dart';

/// The concrete implementation of the [TrackingRepository] contract.
///
/// This repository acts as a mediator between the domain layer (UseCases) and
/// the data layer (DataSources). It is responsible for fetching data models
/// from the data source, converting them into clean domain entities, and
/// handling exceptions by converting them into user-friendly `Failure` objects.
@LazySingleton(as: TrackingRepository)
final class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource _localDataSource;

  TrackingRepositoryImpl({required TrackingLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, Map<TrackingType, TrackingDetailEntity>>>
      getOrCreateTodayDraftTrackingDetails({required String enrollmentId}) {
    // REFINEMENT: Wrap the logic in a generic helper for conciseness and robustness.
    return _tryCatch<Map<TrackingType, TrackingDetailEntity>>(() async {
      final int enrollmentIdInt = int.parse(enrollmentId);
      final modelsMap = await _localDataSource
          .getOrCreateTodayDraftTrackingDetails(enrollmentId: enrollmentIdInt);

      return modelsMap.map((key, model) => MapEntry(key, model.toEntity()));
    });
  }

  @override
  Future<Either<Failure, Unit>> saveDraftTaskProgress(
    TrackingDetailEntity detail,
  ) {
    return _tryCatch<Unit>(() async {
      final detailModel = TrackingDetailModel.fromEntity(detail);
      log("===========================");

      await _localDataSource.saveDraftTrackingDetails([detailModel]);

      return unit; // Return the dartz unit object on success
    });
  }

  @override
  Future<Either<Failure, Unit>> finalizeSession({
    required int trackingId,
    required String finalNotes,
    required int behaviorScore,
  }) {
    return _tryCatch<Unit>(() async {
      await _localDataSource.finalizeDailyTracking(
        trackingId: trackingId,
        finalNotes: finalNotes,
        behaviorScore: behaviorScore,
      );
      return unit;
    });
  }

  /// A generic private helper to wrap data source calls.
  ///
  /// This centralizes the try-catch logic, reducing code duplication and making
  /// the repository methods cleaner and focused on their primary task.
  Future<Either<Failure, T>> _tryCatch<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on CacheException catch (e) {
      log(e.message);
      return Left(CacheFailure(message: e.message));
    } on FormatException catch (e) {
      // Example of handling another specific exception type
      return Left(
        UnknownFailure(message: 'Data formatting error: ${e.message}'),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Mistake>>> getAllMistakes({
    required String enrollmentId,
    TrackingType? type, // <-- NOW OPTIONAL
    int? fromPage,
    int? toPage,
  }) {
    return _tryCatch<List<Mistake>>(() async {
      final int enrollmentIdInt = int.parse(enrollmentId);
      final mistakeModels = await _localDataSource.getAllMistakes(
        enrollmentId: enrollmentIdInt,
        type: type, // Pass it down
        fromPage: fromPage,
        toPage: toPage,
      );
      return mistakeModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<BarChartDatas>>> getErrorAnalysisChartData({
    required String enrollmentId,
    required ChartFilter filter,
  }) {
    return _tryCatch<List<BarChartDatas>>(() async {
      final int enrollmentIdInt = int.parse(enrollmentId);
      final chartData = await _localDataSource.getErrorAnalysisChartData(
        enrollmentId: enrollmentIdInt,
        filter: filter,
      );
      return chartData;
    });
  }
}

// lib/features/daily_tracking/data/datasources/tracking_local_data_source.dart

import 'package:tajalwaqaracademy/features/daily_tracking/data/models/mistake_model.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/data/models/tracking_sync_payload_model.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/ayah.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/mistake.dart';
import 'package:tajalwaqaracademy/features/daily_tracking/domain/entities/stop_point.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/entities/chart_filter.dart';

import '../models/tracking_day_model.dart';

abstract class TrackingLocalDataSource {
  Future<TrackingDayModel> getOrCreateTodayTrackingDetails(
      int userId, int enrollmentId);
  Future<void> saveTaskProgress({
    required int userId,
    required int trackingId,
    required int typeId,
    int? actualAmount,
    StopPoint? from,
    StopPoint? to,
    int? score,
    double? gap,
    String? comment,
    List<MistakeModel>? mistakes,
  });
  Future<void> finalizeSession(int userId, int trackingId);
  Future<List<Mistake>> getAllMistakes(int userId, int studentId);
  Future<Map<ChartFilter, List<Ayah>>> getMistakesAyahs(
      int userId, int studentId, ChartFilter filter);
  Future<Map<ChartFilter, Map<String, int>>> getErrorAnalysisChartData(
      int userId, int studentId, ChartFilter filter);

  // Sync-related methods
  Future<TrackingSyncPayloadModel> getPendingTrackingData(int userId);
  Future<void> markTrackingDataAsSynced(int userId, List<String> syncedUuids);
}

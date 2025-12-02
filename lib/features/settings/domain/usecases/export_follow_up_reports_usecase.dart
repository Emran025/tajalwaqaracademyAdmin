import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_entity.dart';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/repositories/student_repository.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';

@injectable
class ExportFollowUpReportsUseCase
    extends UseCase<String, ExportConfig> {
  final StudentRepository _studentRepository;

  ExportFollowUpReportsUseCase(this._studentRepository);

  @override
  Future<Either<Failure, String>> call(ExportConfig params) async {
    final followUpReportsEither =
        await _studentRepository.getAllFollowUpTrackings();

    return followUpReportsEither.fold(
      (failure) => Left(failure),
      (reports) {
        if (params.fileFormat == DataExportFormat.csv) {
          return Right(_formatAsCsv(reports));
        } else {
          return Right(_formatAsJson(reports));
        }
      },
    );
  }

  String _formatAsCsv(Map<String, List<TrackingEntity>> reports) {
    final List<List<dynamic>> rows = [];
    rows.add([
      'studentId',
      'trackingId',
      'date',
      'note',
      'attendance',
      'behaviorNote',
      'createdAt',
      'updatedAt',
      'detailType',
      'actualAmount',
      'gap',
      'performanceScore',
      'comment',
      'status',
      'from_unitId',
      'from_fromSurah',
      'from_fromPage',
      'from_fromAyah',
      'from_toSurah',
      'from_toPage',
      'from_toAyah',
      'to_unitId',
      'to_fromSurah',
      'to_fromPage',
      'to_fromAyah',
      'to_toSurah',
      'to_toPage',
      'to_toAyah',
      'mistakesJson'
    ]);

    reports.forEach((studentId, trackings) {
      for (final tracking in trackings) {
        if (tracking.details.isEmpty) {
          rows.add([
            studentId,
            tracking.id,
            tracking.date,
            tracking.note,
            tracking.attendanceTypeId,
            tracking.behaviorNote,
            tracking.createdAt,
            tracking.updatedAt,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null
          ]);
        } else {
          for (final detail in tracking.details) {
            final mistakesJson =
                jsonEncode(detail.mistakes.map((m) => m.toJson()).toList());
            rows.add([
              studentId,
              tracking.id,
              tracking.date,
              tracking.note,
              tracking.attendanceTypeId,
              tracking.behaviorNote,
              tracking.createdAt,
              tracking.updatedAt,
              detail.trackingTypeId,
              detail.actualAmount,
              detail.gap,
              detail.score,
              detail.comment,
              detail.status,
              detail.fromTrackingUnitId.unitId,
              detail.fromTrackingUnitId.fromSurah,
              detail.fromTrackingUnitId.fromPage,
              detail.fromTrackingUnitId.fromAyah,
              detail.fromTrackingUnitId.toSurah,
              detail.fromTrackingUnitId.toPage,
              detail.fromTrackingUnitId.toAyah,
              detail.toTrackingUnitId.unitId,
              detail.toTrackingUnitId.fromSurah,
              detail.toTrackingUnitId.fromPage,
              detail.toTrackingUnitId.fromAyah,
              detail.toTrackingUnitId.toSurah,
              detail.toTrackingUnitId.toPage,
              detail.toTrackingUnitId.toAyah,
              mistakesJson
            ]);
          }
        }
      }
    });

    return const ListToCsvConverter().convert(rows);
  }

  String _formatAsJson(Map<String, List<TrackingEntity>> reports) {
    final serializableReports = reports.map((key, value) {
      return MapEntry(
          key, value.map((tracking) => tracking.toJson()).toList());
    });
    return jsonEncode(serializableReports);
  }
}

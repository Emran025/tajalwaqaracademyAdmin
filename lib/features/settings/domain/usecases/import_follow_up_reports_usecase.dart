import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:tajalwaqaracademy/core/models/attendance_type.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_detail_entity.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/tracking_entity.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/repositories/student_repository.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_summary.dart';

@injectable
class ImportFollowUpReportsUseCase
    extends UseCase<ImportSummary, ImportConfig> {
  final StudentRepository _studentRepository;

  ImportFollowUpReportsUseCase(this._studentRepository);

  @override
  Future<Either<Failure, ImportSummary>> call(ImportConfig params) async {
    try {
      final file = File(params.filePath);
      final fileContent = await file.readAsString();

      if (params.filePath.endsWith('.csv')) {
        return _importCsv(fileContent, params.conflictResolution);
      } else if (params.filePath.endsWith('.json')) {
        return _importJson(fileContent, params.conflictResolution);
      } else {
        return Left(
            CacheFailure(message: 'Unsupported file format for import.'));
      }
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to read import file: $e'));
    }
  }

  Future<Either<Failure, ImportSummary>> _importCsv(
      String csvData, ConflictResolution conflictResolution) async {
    final List<List<dynamic>> rows =
        const CsvToListConverter().convert(csvData);
    if (rows.length < 2) {
      return Left(CacheFailure(
          message: 'CSV file must have a header and at least one data row.'));
    }

    final header = rows.first.map((e) => e.toString()).toList();
    final dataRows = rows.skip(1);

    final trackingsByStudent = <String, Map<String, List<Map<String, dynamic>>>>{};
    final errorMessages = <String>[];
    int successfulRows = 0;

    for (final row in dataRows) {
      try {
        final rowData = Map<String, dynamic>.fromIterables(header, row);
        final studentId = rowData['studentId'] as String;
        final trackingId = rowData['trackingId'] as String;

        trackingsByStudent.putIfAbsent(studentId, () => {});
        trackingsByStudent[studentId]!.putIfAbsent(trackingId, () => []);
        trackingsByStudent[studentId]![trackingId]!.add(rowData);
        successfulRows++;
      } catch (e) {
        errorMessages.add('Error parsing row: ${row.join(',')}. Error: $e');
      }
    }

    final result = <String, List<TrackingEntity>>{};
    trackingsByStudent.forEach((studentId, trackingsData) {
      result[studentId] = trackingsData.entries.map((entry) {
        final details = entry.value
            .map((rowData) => TrackingDetailEntity.fromCsvRow(rowData))
            .toList();
        return TrackingEntity.fromCsvRow(entry.value.first, details);
      }).toList();
    });

    await _studentRepository.importFollowUpTrackings(
      trackings: result,
      conflictResolution: conflictResolution,
    );

    return Right(ImportSummary(
      totalRows: dataRows.length,
      successfulRows: successfulRows,
      failedRows: errorMessages.length,
      errorMessages: errorMessages,
    ));
  }

  Future<Either<Failure, ImportSummary>> _importJson(
      String jsonData, ConflictResolution conflictResolution) async {
    final Map<String, dynamic> decodedData = jsonDecode(jsonData);
    final trackingsByStudent = <String, List<TrackingEntity>>{};
    int totalRows = 0;

    decodedData.forEach((studentId, trackingsData) {
      final trackings = (trackingsData as List)
          .map((data) => TrackingEntity.fromJson(data as Map<String, dynamic>))
          .toList();
      trackingsByStudent[studentId] = trackings;
      totalRows += trackings.length;
    });

    await _studentRepository.importFollowUpTrackings(
      trackings: trackingsByStudent,
      conflictResolution: conflictResolution,
    );

    return Right(ImportSummary(
      totalRows: totalRows,
      successfulRows: totalRows,
      failedRows: 0,
    ));
  }
}

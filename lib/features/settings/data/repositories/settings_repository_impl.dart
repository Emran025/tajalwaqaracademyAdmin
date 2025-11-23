// path: lib/features/settings/data/repositories/settings_repository_impl.dart

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/data/models/student_model.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/data/models/teacher_model.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_export.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_summary.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../domain/entities/privacy_policy_entity.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/core_data_local_data_source.dart';
import '../datasources/settings_local_data_source.dart';
import '../datasources/settings_remote_data_source.dart';

/// The concrete implementation of the [SettingsRepository] contract.
///
/// This class orchestrates data operations by delegating tasks to specific
/// data sources. It is responsible for:
/// 1.  Deciding whether to fetch data from a local or remote source.
/// 2.  Checking for network connectivity before making remote calls.
/// 3.  Catching exceptions from the data sources and converting them into
///     domain-layer-friendly [Failure] objects.
/// 4.  (If needed) Converting data models from the data layer into domain entities.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;
  final SettingsRemoteDataSource remoteDataSource;
  final CoreDataLocalDataSource coreDataSource;
  final NetworkInfo networkInfo;

  /// Constructs a [SettingsRepositoryImpl].
  ///
  /// It requires abstractions of its data sources and network info,
  /// adhering to Dependency Injection principles.
  SettingsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.coreDataSource,
    required this.networkInfo,
  });

  // --- LOCAL DATA OPERATIONS ---

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveTheme(AppThemeType themeType) async {
    try {
      await localDataSource.saveTheme(themeType);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setAnalyticsPreference(bool isEnabled) async {
    try {
      await localDataSource.setAnalyticsPreference(isEnabled);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationsPreference(
    bool isEnabled,
  ) async {
    try {
      await localDataSource.setNotificationsPreference(isEnabled);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  // --- REMOTE DATA OPERATIONS ---

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    return await _getRemoteData<UserProfileEntity>(
      () => remoteDataSource.getUserProfile().then((model) => model.toEntity()),
    );
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(
    UserProfileEntity profile,
  ) async {
    return await _getRemoteData<void>(
      () => remoteDataSource.updateUserProfile(profile),
    );
  }

  /// Fetches the latest privacy policy using a "remote-first with cache-fallback" strategy.
  ///
  /// This method first attempts to retrieve the policy from the remote server to ensure
  /// the user has the most up-to-date version. If the remote call is successful,
  /// it updates the local cache in the background. If the remote call fails
  /// (e.g., due to a server error or lack of internet), it gracefully falls back
  /// to loading the policy from the local cache.
  @override
  Future<Either<Failure, PrivacyPolicyEntity>> getLatestPolicy() async {
    // if (await networkInfo.isConnected) {
    try {
      // 1. Attempt to fetch from the remote data source.
      final remotePolicyModel = await remoteDataSource.getLatestPolicy();

      // 2. If successful, save the fresh data to the local cache.
      //    This is a "fire and forget" operation; we don't await it, and we
      //    catch potential errors to prevent them from crashing the main flow.
      localDataSource.savePolicy(remotePolicyModel).catchError((_) {
        // Optional: Log this error to a monitoring service.
        // For now, we fail silently as the user has already received the data.
      });

      // 3. Map the data model to a domain entity and return success.
      return Right(remotePolicyModel.toEntity());
    } on ServerException catch (e) {
      // 4. A server error occurred. Fall back to the local cache.
      return _getPolicyFromLocalCache(
        fallbackFailure: ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    }
    // } else {
    //   // 5. No internet connection. Go directly to the local cache.
    //   return _getPolicyFromLocalCache(
    //     fallbackFailure: NetworkFailure(
    //       message: 'No internet connection detected.',
    //     ),
    //   );
    // }
  }

  /// Private helper to fetch the policy from the local cache and handle errors.
  ///
  /// This reduces code duplication for the cache-access logic.
  /// It takes a [fallbackFailure] to return if the cache is also empty,
  /// ensuring the original error context (Network or Server) is preserved.
  Future<Either<Failure, PrivacyPolicyEntity>> _getPolicyFromLocalCache({
    required Failure fallbackFailure,
  }) async {
    try {
      final localPolicyModel = await localDataSource.getLatestPolicy();
      return Right(localPolicyModel.toEntity());
    } on CacheException {
      // The cache is also empty. Return the original failure that led us here.
      return Left(fallbackFailure);
    }
  }

  /// A generic helper method to handle all remote data calls.
  ///
  /// This private utility encapsulates the boilerplate logic of checking network
  /// connectivity and handling `ServerException`s, making the public methods
  /// cleaner and more readable (DRY principle).
  Future<Either<Failure, T>> _getRemoteData<T>(
    Future<T> Function() call,
  ) async {
    // if (await networkInfo.isConnected) {
    //   try {
    final result = await call();
    return Right(result);
    //   } on ServerException catch (e) {
    //     return Left(
    //       ServerFailure(message: e.message, statusCode: e.statusCode),
    //     );
    //   }
    // } else {
    //   return Left(NetworkFailure(message: 'No internet connection detected.'));
    // }
  }

  @override
  Future<Either<Failure, String>> exportData(
      {required ExportConfig config}) async {
    try {
      final List<StudentModel> students = [];
      if (config.entityTypes.contains(EntityType.student)) {
        students.addAll(await coreDataSource.getStudentsForExport());
      }
      final List<TeacherModel> teachers = [];
      if (config.entityTypes.contains(EntityType.teacher)) {
        teachers.addAll(await coreDataSource.getTeachersForExport());
      }
      final data = {
        'students': students.map((s) => s.toJson()).toList(),
        'teachers': teachers.map((t) => t.toJson()).toList(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String();
      final fileExtension = config.fileFormat;
      final file = File('${directory.path}/export_$timestamp.$fileExtension');

      if (fileExtension == 'json') {
        await file.writeAsString(jsonEncode(data));
        return Right(file.path);
      } else if (fileExtension == 'csv') {
        final archive = Archive();
        if (students.isNotEmpty) {
          final csvData = <List<dynamic>>[];
          csvData.add(StudentModel.csvHeader());
          csvData.addAll(students.map((s) => s.toCsv()));
          final csvString = const ListToCsvConverter().convert(csvData);
          archive.addFile(
              ArchiveFile('students.csv', csvString.length, utf8.encode(csvString)));
        }
        if (teachers.isNotEmpty) {
          final csvData = <List<dynamic>>[];
          csvData.add(TeacherModel.csvHeader());
          csvData.addAll(teachers.map((t) => t.toCsv()));
          final csvString = const ListToCsvConverter().convert(csvData);
          archive.addFile(
              ArchiveFile('teachers.csv', csvString.length, utf8.encode(csvString)));
        }
        final zipFile = File('${directory.path}/export_$timestamp.zip');
        final encoder = ZipFileEncoder();
        encoder.create(zipFile.path);
        for (final file in archive) {
          encoder.addFile(file);
        }
        encoder.close();
        return Right(zipFile.path);
      } else {
        return Left(
            CacheFailure(message: 'Unsupported export file format: $fileExtension'));
      }
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ImportSummary>> importData(
      {required String filePath, required ImportConfig config}) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final errorMessages = <String>[];
      int successfulRows = 0;
      int totalRows = 0;

      if (filePath.endsWith('.json')) {
        final data = jsonDecode(content) as Map<String, dynamic>;
        if (config.entityType == EntityType.student &&
            data.containsKey('students')) {
          final studentsData = data['students'] as List;
          totalRows = studentsData.length;
          final studentsToImport = <StudentModel>[];
          for (var i = 0; i < totalRows; i++) {
            try {
              studentsToImport.add(StudentModel.fromMap(
                  studentsData[i] as Map<String, dynamic>));
            } catch (e) {
              errorMessages.add('Row ${i + 1}: Invalid student data - ${e.toString()}');
            }
          }
          if (studentsToImport.isNotEmpty) {
            successfulRows = await coreDataSource.importStudents(
                studentsToImport, config.conflictResolution.name);
          }
        } else if (config.entityType == EntityType.teacher &&
            data.containsKey('teachers')) {
          final teachersData = data['teachers'] as List;
          totalRows = teachersData.length;
          final teachersToImport = <TeacherModel>[];
          for (var i = 0; i < totalRows; i++) {
            try {
              teachersToImport.add(TeacherModel.fromMap(
                  teachersData[i] as Map<String, dynamic>));
            } catch (e) {
              errorMessages.add('Row ${i + 1}: Invalid teacher data - ${e.toString()}');
            }
          }
          if (teachersToImport.isNotEmpty) {
            successfulRows = await coreDataSource.importTeachers(
                teachersToImport, config.conflictResolution.name);
          }
        }
      } else if (filePath.endsWith('.csv')) {
        final csvData = const CsvToListConverter().convert(content);
        if (csvData.isNotEmpty) {
          final header = csvData[0];
          final dataRows = csvData.sublist(1);
          totalRows = dataRows.length;

          if (config.entityType == EntityType.student) {
            final studentsToImport = <StudentModel>[];
            for (var i = 0; i < totalRows; i++) {
              try {
                final row = dataRows[i];
                final map = Map<String, dynamic>.fromIterables(
                    header.map((e) => e.toString()), row);
                studentsToImport.add(StudentModel.fromMap(map));
              } catch (e) {
                errorMessages.add('Row ${i + 1}: Invalid student data - ${e.toString()}');
              }
            }
            if (studentsToImport.isNotEmpty) {
              successfulRows = await coreDataSource.importStudents(
                  studentsToImport, config.conflictResolution.name);
            }
          } else if (config.entityType == EntityType.teacher) {
            final teachersToImport = <TeacherModel>[];
            for (var i = 0; i < totalRows; i++) {
              try {
                final row = dataRows[i];
                final map = Map<String, dynamic>.fromIterables(
                    header.map((e) => e.toString()), row);
                teachersToImport.add(TeacherModel.fromMap(map));
              } catch (e) {
                errorMessages.add('Row ${i + 1}: Invalid teacher data - ${e.toString()}');
              }
            }
            if (teachersToImport.isNotEmpty) {
              successfulRows = await coreDataSource.importTeachers(
                  teachersToImport, config.conflictResolution.name);
            }
          }
        }
      }

      return Right(ImportSummary(
        totalRows: totalRows,
        successfulRows: successfulRows,
        failedRows: totalRows - successfulRows,
        errorMessages: errorMessages,
      ));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

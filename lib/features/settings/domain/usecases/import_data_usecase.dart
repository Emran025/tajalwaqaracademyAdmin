// path: lib/features/settings/domain/usecases/import_data_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/import_config.dart';
import '../entities/import_summary.dart';
import '../repositories/settings_repository.dart';

/// Imports application data from a file.
@lazySingleton

class ImportDataUseCase implements UseCase<ImportSummary, ImportDataParams> {
  final SettingsRepository repository;

  ImportDataUseCase(this.repository);

  @override
  Future<Either<Failure, ImportSummary>> call(ImportDataParams params) async {
    return await repository.importData(
        filePath: params.filePath, config: params.config);
  }
}

/// The parameters for the [ImportDataUseCase].
class ImportDataParams extends Equatable {
  final String filePath;
  final ImportConfig config;

  const ImportDataParams({required this.filePath, required this.config});

  @override
  List<Object?> get props => [filePath, config];
}

// path: lib/features/settings/domain/usecases/export_data_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/export_config.dart';
import '../repositories/settings_repository.dart';

/// Exports application data based on a given configuration.
@lazySingleton

class ExportDataUseCase implements UseCase<String, ExportDataParams> {
  final SettingsRepository repository;

  ExportDataUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportDataParams params) async {
    return await repository.exportData(config: params.config);
  }
}

/// The parameters for the [ExportDataUseCase].
class ExportDataParams extends Equatable {
  final ExportConfig config;

  const ExportDataParams({required this.config});

  @override
  List<Object?> get props => [config];
}

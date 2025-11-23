// path: lib/features/settings/domain/entities/export_config.dart

import 'package:equatable/equatable.dart';
import 'import_export.dart';

/// Defines the configuration for a data export operation.
class ExportConfig extends Equatable {
  /// The list of entity types to be exported (e.g., 'students', 'teachers').
  final List<EntityType> entityTypes;

  /// The desired file format for the export (e.g., 'csv', 'json').
  final DataExportFormat fileFormat;

  const ExportConfig({
    required this.entityTypes,
    required this.fileFormat,
  });

  @override
  List<Object?> get props => [entityTypes, fileFormat];
}

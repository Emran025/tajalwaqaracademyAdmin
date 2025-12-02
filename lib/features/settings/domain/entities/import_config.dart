// path: lib/features/settings/domain/entities/import_config.dart

import 'package:equatable/equatable.dart';
import 'import_export.dart';

/// Defines the configuration for a data import operation.
class ImportConfig extends Equatable {
  /// The entity type to be imported (e.g., 'students', 'teachers').
  final EntityType entityType;

  /// The conflict resolution strategy (e.g., 'skip', 'overwrite').
  final ConflictResolution conflictResolution;

  /// The path to the file to be imported.
  final String filePath;

  const ImportConfig({
    required this.entityType,
    required this.conflictResolution,
    this.filePath = '',
  });

  ImportConfig copyWith({
    EntityType? entityType,
    ConflictResolution? conflictResolution,
    String? filePath,
  }) {
    return ImportConfig(
      entityType: entityType ?? this.entityType,
      conflictResolution: conflictResolution ?? this.conflictResolution,
      filePath: filePath ?? this.filePath,
    );
  }

  @override
  List<Object?> get props => [entityType, conflictResolution, filePath];
}

// path: lib/features/settings/domain/entities/import_config.dart

import 'package:equatable/equatable.dart';
import 'import_export.dart';

/// Defines the configuration for a data import operation.
class ImportConfig extends Equatable {
  /// The entity type to be imported (e.g., 'students', 'teachers').
  final EntityType entityType;

  /// The conflict resolution strategy (e.g., 'skip', 'overwrite').
  final ConflictResolution conflictResolution;

  const ImportConfig({
    required this.entityType,
    required this.conflictResolution,
  });

  @override
  List<Object?> get props => [entityType, conflictResolution];
}

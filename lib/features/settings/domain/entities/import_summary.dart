// path: lib/features/settings/domain/entities/import_summary.dart

import 'package:equatable/equatable.dart';

/// Represents a detailed summary of a data import operation.
class ImportSummary extends Equatable {
  /// The total number of rows processed from the source file.
  final int totalRows;

  /// The number of rows that were successfully imported.
  final int successfulRows;

  /// The number of rows that failed to import.
  final int failedRows;

  /// A list of detailed error messages for each failed row.
  final List<String> errorMessages;

  const ImportSummary({
    required this.totalRows,
    required this.successfulRows,
    required this.failedRows,
    this.errorMessages = const [],
  });

  @override
  List<Object?> get props =>
      [totalRows, successfulRows, failedRows, errorMessages];
}

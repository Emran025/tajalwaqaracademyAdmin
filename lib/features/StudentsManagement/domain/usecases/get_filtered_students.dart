// lib/features/students/domain/usecases/get_student_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/active_status.dart';
import '../../../../core/models/report_frequency.dart';
import '../entities/student_list_item_entity.dart';
import '../repositories/student_repository.dart';
import 'usecase.dart';

@lazySingleton
class FetchFilteredStudentsUseCase extends UseCase<List<StudentListItemEntity>, GetFilteredStudentsParams> {
  final StudentRepository repository;

  FetchFilteredStudentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StudentListItemEntity>>> call(
    GetFilteredStudentsParams params,
  ) async {
    return await repository.getFilteredStudents(
      status: params.status,
      halaqaId: params.halaqaId,
      trackDate: params.trackDate, // Can be null
      frequencyCode: params.frequencyCode,
    );
  }
}


class GetFilteredStudentsParams extends Equatable {
 final ActiveStatus? status;
 final int? halaqaId;
 final DateTime? trackDate;
 final Frequency? frequencyCode;

  const GetFilteredStudentsParams({
    this.status,
    this.halaqaId,
    this.trackDate,
    this.frequencyCode,
  });

  @override
  List<Object?> get props => [status, halaqaId, trackDate, frequencyCode];
}

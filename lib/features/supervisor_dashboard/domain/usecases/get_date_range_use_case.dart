// repository/student_timeline_repository.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/features/supervisor_dashboard/domain/repositories/repository.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/models/user_role.dart';

@lazySingleton
class GetDateRangeUseCase {
  final SupervisorTimelineRepository repository;

  GetDateRangeUseCase({required this.repository});

  Future<Either<Failure, DateTimeRange>> call(UserRole entityType) async {
    try {
      final range = await repository.getAvailableDateRange(entityType);
      return Right(range);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

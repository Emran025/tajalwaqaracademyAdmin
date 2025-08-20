// lib/features/teachers/domain/usecases/upsert_teacher.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/teacher_entity.dart';
import '../repositories/teacher_repository.dart';
import 'usecase.dart';

@lazySingleton
class UpsertTeacher extends UseCase<TeacherDetailEntity, TeacherDetailEntity> {
  final TeacherRepository repository;

  UpsertTeacher(this.repository);

  @override
  Future<Either<Failure, TeacherDetailEntity>> call(
    TeacherDetailEntity teacher,
  ) async {
    return await repository.upsertTeacher(teacher);
  }
}
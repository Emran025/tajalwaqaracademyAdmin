// lib/features/students/domain/usecases/upsert_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/error_model.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';
import 'usecase.dart';

@lazySingleton
class UpsertStudent extends UseCase<StudentDetailEntity, StudentDetailEntity> {
  final StudentRepository repository;

  UpsertStudent(this.repository);

  @override
  Future<Either<Failure, StudentDetailEntity>> call(
    StudentDetailEntity student,
  ) async {
    return await repository.upsertStudent(student);
  }
}

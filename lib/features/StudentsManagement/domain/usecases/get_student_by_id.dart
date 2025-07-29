// lib/features/students/domain/usecases/get_student_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/error_model.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';
import 'usecase.dart';

@lazySingleton
class GetStudentById extends UseCase<StudentDetailEntity, String> {
  final StudentRepository repository;

  GetStudentById(this.repository);

  @override
  Future<Either<Failure, StudentDetailEntity>> call(String studentId) async {
    return await repository.getStudentById(studentId);
  }
}

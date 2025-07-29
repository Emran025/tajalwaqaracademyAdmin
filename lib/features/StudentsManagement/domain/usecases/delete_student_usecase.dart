// lib/features/students/domain/usecases/delete_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/errors/error_model.dart';

import '../repositories/student_repository.dart';
import 'usecase.dart';

@lazySingleton
class DeleteStudentUseCase extends UseCase<Unit, String> {
  final StudentRepository repository;

  DeleteStudentUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String studentId) async {
    return await repository.deleteStudent(studentId);
  }
}

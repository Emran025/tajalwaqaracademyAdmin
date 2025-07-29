// lib/features/students/domain/usecases/delete_student.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/errors/error_model.dart';

import '../repositories/student_repository.dart';
import 'usecase.dart';

@lazySingleton
class FetchMoreStudentsUseCase extends UseCase<Unit, int> {
  final StudentRepository repository;

  FetchMoreStudentsUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int page) async {
    return await repository.fetchMoreStudents(page: page);
  }
}

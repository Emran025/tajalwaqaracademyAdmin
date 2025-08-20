

// lib/features/teachers/domain/usecases/delete_teacher.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/features/TeachersManagement/domain/usecases/usecase.dart';

import '../repositories/teacher_repository.dart';

@lazySingleton
class FetchMoreTeachersUseCase extends UseCase<Unit, int > {
  final TeacherRepository repository;

  FetchMoreTeachersUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int page) async {
    return await repository.fetchMoreTeachers(page:page);
  }
}
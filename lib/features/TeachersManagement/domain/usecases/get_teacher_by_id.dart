// lib/features/teachers/domain/usecases/get_teacher_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/error_model.dart';
import '../entities/teacher_entity.dart';
import '../repositories/teacher_repository.dart';
import 'usecase.dart';

@lazySingleton
class GetTeacherById extends UseCase<TeacherDetailEntity, String> {
  final TeacherRepository repository;

  GetTeacherById(this.repository);

  @override
  Future<Either<Failure, TeacherDetailEntity>> call(String teacherId) async {
    return await repository.getTeacherById(teacherId);
  }
}

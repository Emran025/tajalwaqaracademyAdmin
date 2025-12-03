import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/repositories/student_repository.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';

@injectable
class ExportFollowUpReportsUseCase extends UseCase<String, ExportConfig> {

  final StudentRepository _studentRepository;
  ExportFollowUpReportsUseCase(this._studentRepository);

  @override
  Future<Either<Failure, String>> call(ExportConfig params) async {
    // تم نقل المنطق بالكامل إلى داخل الدالة في الريبو
    return await _studentRepository.exportFollowUpReports(config: params);
  }
}
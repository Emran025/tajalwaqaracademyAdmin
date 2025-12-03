import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:tajalwaqaracademy/core/error/failures.dart';
import 'package:tajalwaqaracademy/core/usecases/usecase.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/repositories/student_repository.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_summary.dart';


@injectable
class ImportFollowUpReportsUseCase
    extends UseCase<ImportSummary, ImportConfig> {
  final StudentRepository _studentRepository;

  ImportFollowUpReportsUseCase(this._studentRepository);

  @override
  Future<Either<Failure, ImportSummary>> call(ImportConfig params) async {
    // تم نقل المنطق بالكامل إلى داخل الدالة في الريبو
    return await _studentRepository.importFollowUpReports(config: params);
  }
}
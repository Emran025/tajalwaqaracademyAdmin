import 'package:tajalwaqaracademy/features/settings/domain/entities/export_config.dart';
import 'package:tajalwaqaracademy/features/settings/domain/entities/import_config.dart';

String toDisplayString(dynamic anEnum) {
  switch (anEnum) {
    case ExportableData.students:
      return 'بيانات الطلاب';
    case ExportableData.teachers:
      return 'بيانات المعلمين';
    case ExportableData.halaqas:
      return 'بيانات الحلقات';
    case DataExportFormat.csv:
      return 'CSV';
    case DataExportFormat.json:
      return 'JSON';
    case ConflictStrategy.skip:
      return 'تجاهل';
    case ConflictStrategy.overwrite:
      return 'الكتابة فوق';
    default:
      return anEnum.toString().split('.').last;
  }
}

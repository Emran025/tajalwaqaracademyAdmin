import 'package:tajalwaqaracademy/core/api/end_ponits.dart';

import '../../domain/entities/success_entity.dart';

class SuccessModel extends SuccessEntity {


  SuccessModel({
    required super.status,
    required super.message,
  });

  factory SuccessModel.fromJson(Map<String, dynamic> jsonData) {
    return SuccessModel(
        status: jsonData[ApiKey.status] ?? '',
        message: jsonData[ApiKey.message] ?? '');
  }
}

import 'package:tajalwaqaracademy/core/api/end_ponits.dart';

import '../entities/success_entity.dart';

class SuccessModel extends SuccessEntity {
  SuccessModel({super.status, super.message});

  factory SuccessModel.fromJson(Map<String, dynamic> jsonData) {
    return SuccessModel(
      status: jsonData[ApiKey.status] ?? '',
      message: jsonData[ApiKey.message] ?? '',
    );
  }

  SuccessEntity toEntity() {
    return SuccessEntity(status: status, message: message);
  }
}

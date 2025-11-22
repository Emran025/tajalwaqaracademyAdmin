// ignore_for_file: file_names, unnecessary_new, non_constant_identifier_names

import 'package:tajalwaqaracademy/features/auth/domain/entities/states_entity.dart';

class StatesModel extends StatesEntity{
  StatesModel({
    required super.id,
    required super.name,
    required super.countryId,
    required super.status,
  });

  factory StatesModel.fromJson(Map<String, dynamic> json) {
    return StatesModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      countryId: json['countryId'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

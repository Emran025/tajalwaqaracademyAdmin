import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/halqa_entity.dart';

@immutable
final class AssignedHalaqasModel {
  final String id;
  final String name;
  final String avatar;

  const AssignedHalaqasModel({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory AssignedHalaqasModel.fromJson(Map<String, dynamic> json) {
    return AssignedHalaqasModel(
      id: (json['id'] as int).toString(),
      name: json['name'] as String? ?? 'Unnamed Halqa',
      avatar: json['avatar'] as String? ?? 'assets/images/logo2.png',
    );
  }

   AssignedHalaqasEntity toEntity() {
    return AssignedHalaqasEntity(id: id, name: name, avatar: avatar );
  }
}

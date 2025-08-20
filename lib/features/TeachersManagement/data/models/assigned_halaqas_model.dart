import 'package:flutter/material.dart';

import '../../../StudentsManagement/domain/entities/halqa_entity.dart';

@immutable
final class AssignedHalaqasModel {
  final String id;
  final String name;
  final String? avatar;
  final String? enrolledAt;

  const AssignedHalaqasModel({required this.id, required this.name, this.avatar , this.enrolledAt});

  factory AssignedHalaqasModel.fromJson(Map<String, dynamic> json) {
    return AssignedHalaqasModel(
      id: (json['id'] as int).toString(),
      name: json['name'] as String? ?? 'Unnamed Halqa',
      avatar: json['avatar'] as String?,
      enrolledAt: json['enrolledAt'] as String?,
    );
  }
  
  AssignedHalaqasEntity toEntity() {
    return AssignedHalaqasEntity(id: id, name: name, avatar: avatar ?? '', enrolledAt :enrolledAt??"2025-07-08 22:21:36" );
  }
}
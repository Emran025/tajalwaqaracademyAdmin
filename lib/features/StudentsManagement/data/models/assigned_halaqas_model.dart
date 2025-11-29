import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../features/StudentsManagement/domain/entities/halqa_entity.dart';
import 'package:uuid/uuid.dart';

@immutable
final class AssignedHalaqasModel {
  final String id; // Represents the 'uuid' of the assignment record
  final String name;
  final String avatar;
  final String? enrollmentId;
  final String enrolledAt;
  final String halaqaId; // Halqa UUID

  const AssignedHalaqasModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.enrolledAt,
    this.enrollmentId,
    required this.halaqaId,
  });

  factory AssignedHalaqasModel.fromJson(Map<String, dynamic>? json) {
    return json != null
        ? AssignedHalaqasModel(
            // Generate a unique UUID for the assignment itself
            id: const Uuid().v4(),
            name: json['name'] as String? ?? 'Unnamed Halqa',
            avatar: json['avatar'] as String? ?? 'assets/images/logo2.png',
            enrolledAt:
                json['enrolledAt'] as String? ??
                DateTime.now().toIso8601String(),
            halaqaId: (json['id'] as int)
                .toString(), // Assuming API gives integer ID for halqa
          )
        : AssignedHalaqasModel(
            // Generate a unique UUID for the assignment itself
            id: const Uuid().v4(),
            name: 'Unnamed Halqa',
            avatar: 'assets/images/logo2.png',
            enrolledAt: DateTime.now().toIso8601String(),
            halaqaId: '0', // Assuming API gives integer ID for halqa
          );
  }

  factory AssignedHalaqasModel.fromMap(Map<String, dynamic> map) {
    // final playloudJsonString = map['playloud'] as String? ?? '{}';

    final playloudData = jsonDecode(map['playloud']) as Map<String, dynamic>;

    return AssignedHalaqasModel(
      id: map['uuid'] as String,
      enrollmentId: (map['id'] as int).toString(),
      // 'name' and 'avatar' for the halqa should be JOINed in the query
      name: playloudData['name'] as String? ?? 'النور',
      avatar: playloudData['avatar'] as String? ?? 'assets/images/logo2.png',
      enrolledAt: map['assignedAt'] as String,
      halaqaId: (map['halqaId'] as int).toString(),
    );
  }

  Map<String, dynamic> toMap(int studentId) {
    return {
      "uuid": id,
      "halqaId": halaqaId,
      "studentId": studentId,
      "assignedAt": enrolledAt,
      "playloud": jsonEncode({"avatar": avatar, "name": name}),
      "lastModified": DateTime.now().millisecondsSinceEpoch,
      "isDeleted": halaqaId == "0" ? 1 : 0,
    };
  }

  AssignedHalaqasEntity toEntity() {
    return AssignedHalaqasEntity(
      id: id,
      enrollmentId: enrollmentId,
      name: name,
      avatar: avatar,
      enrolledAt: enrolledAt,
      halaqaId: halaqaId,
    );
  }

  factory AssignedHalaqasModel.fromEntity(AssignedHalaqasEntity entity) {
    return AssignedHalaqasModel(
      id: entity.id,
      name: entity.name,
      avatar: entity.avatar,
      enrolledAt: entity.enrolledAt,
      halaqaId: entity.halaqaId,
    );
  }
}

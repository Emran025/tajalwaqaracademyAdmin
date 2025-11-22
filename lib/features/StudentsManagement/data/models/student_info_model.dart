import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../../../core/models/active_status.dart';
import '../../../../../core/models/gender.dart';
import '../../../../../features/StudentsManagement/data/models/follow_up_plan_model.dart';
import '../../../../../features/StudentsManagement/domain/entities/student_list_item_entity.dart';

import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_info_entity.dart';
import 'assigned_halaqas_model.dart';
import 'student_model.dart';

/// The data model for a Student, serving as the data transfer object (DTO)
/// for the data layer. It is a plain, immutable Dart object.
///
/// This single model is capable of representing the full student data and can be
/// transformed into either a lightweight [StudentListItemEntity] for lists or a
/// complete [StudentDetailEntity] for profile views.

@immutable
final class StudentInfoModel {
  final StudentModel studentModel; // The UUID string
  final AssignedHalaqasModel assignedHalaqa; // <<< Single Halqa, not a list
  final FollowUpPlanModel followUpPlan; // <<< FollowUpPlan object

  const StudentInfoModel({
    required this.studentModel,
    required this.assignedHalaqa, // Changed to singular
    required this.followUpPlan, // New property
  });

  // /// Creates a [StudentInfoModel] from a JSON map received from an API.
  factory StudentInfoModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the nested list of halqas.
    if (json['name'] == null) {
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
      log("message");
    }
    final studentModel = StudentModel(
      id: json['uuid'] as String? ?? (json['id'] as int? ?? 0).toString(),
      name: json['name'] as String? ?? 'Unknown Name',
      gender: Gender.fromLabel(
        json['gender'] as String? ?? Gender.male.labelAr.toLowerCase(),
      ),
      birthDate: json['birthDate'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      phoneZone: json['phoneZone'] as String?,
      whatsappPhone: json['whatsappPhone'] as String?,
      whatsappZone: json['whatsappZone'] as String?,
      bio: json['bio'] as String?,
      experienceYears: json['experienceYears'] as int? ?? 0,
      country: json['country'] as String? ?? '',
      residence: json['residence'] as String? ?? '',
      city: json['city'] as String? ?? '',
      availableTime: json['availableTime'] as String?,
      status: ActiveStatus.fromLabel(json['status'] as String? ?? 'inactive'),
      stopReasons: json['stopReasons'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      memorizationLevel: json['memorizationLevel'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
    final assignedHalaqa = AssignedHalaqasModel.fromJson(
      json['halaqa'] as Map<String, dynamic>?,
    );

    final followUpPlan = FollowUpPlanModel.fromJson(
      json['followUpPlan'] as Map<String, dynamic>,
    );

    return StudentInfoModel(
      assignedHalaqa: assignedHalaqa,
      studentModel: studentModel,
      followUpPlan: followUpPlan,
    );
  }

  /// Converts this data model into a lightweight [StudentInfoEntity].
  StudentInfoEntity toStudentInfoEntity() {
    return StudentInfoEntity(
      assignedHalaqa: assignedHalaqa.toEntity(),
      studentDetailEntity: studentModel.toDetailEntity(),
      followUpPlan: followUpPlan.toEntity(),
    );
  }

  factory StudentInfoModel.fromEntity(StudentInfoEntity student) {
    return StudentInfoModel(
      studentModel: StudentModel.fromEntity(student.studentDetailEntity),
      assignedHalaqa: AssignedHalaqasModel.fromEntity(student.assignedHalaqa),
      followUpPlan: FollowUpPlanModel.fromEntity(student.followUpPlan),
    );
  }
}

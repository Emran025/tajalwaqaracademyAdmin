import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';
import 'package:tajalwaqaracademy/features/StudentsManagement/domain/entities/student_list_item_entity.dart';

import '../../domain/entities/student_entity.dart';

/// The data model for a Student, serving as the data transfer object (DTO)
/// for the data layer. It is a plain, immutable Dart object.
///
/// This single model is capable of representing the full student data and can be
/// transformed into either a lightweight [StudentListItemEntity] for lists or a
/// complete [StudentDetailEntity] for profile views.

@immutable
final class StudentModel {
  final String id; // The UUID string
  final String name;
  final Gender gender;
  final String birthDate;
  final String email;
  final String phone;
  final String? phoneZone;
  final String? whatsappZone;
  final String? whatsappPhone;
  final String? bio;
  final int experienceYears;
  final String country;
  final String residence;
  final String city;
  final String? availableTime;
  final ActiveStatus status;
  final String? stopReasons;
  final String? avatar;
  final String? updatedAt;
  final String? createdAt;
  final String memorizationLevel;
  final String qualification;
  final bool isDeleted;

  const StudentModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.email,
    required this.phone,
    this.phoneZone,
    this.whatsappPhone,
    this.whatsappZone,
    this.bio,
    required this.experienceYears,
    required this.country,
    required this.residence,
    required this.city,
    this.availableTime,
    required this.status,
    this.stopReasons,
    this.avatar,
    this.createdAt,
    this.updatedAt,

    required this.memorizationLevel,
    required this.qualification,
    required this.isDeleted,
  });

  factory StudentModel.fromMap(
    Map<String, dynamic> map, {
    bool fromDb = false,
  }) {
    return StudentModel(
      id: (map['uuid'] as String?) ?? (map['id'] as int? ?? 0).toString(),
      name: map['name'] as String? ?? 'Unknown Name',
      gender: Gender.fromId(map['gender'] as int? ?? Gender.male.id),
      birthDate: map['birthDate'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      phoneZone: map['phoneZone'] as String?,
      // التعامل مع الاختلاف في الأسماء
      whatsappPhone:
          (map['whatsappPhone'] as String?) ?? (map['whatsapp'] as String?),
      whatsappZone: map['whatsappZone'] as String?,
      bio: map['bio'] as String?,
      experienceYears: map['experienceYears'] as int? ?? 0,
      country: map['country'] as String? ?? '',
      residence: map['residence'] as String? ?? '',
      city: map['city'] as String? ?? '',
      availableTime: map['availableTime'] as String?,
      status: ActiveStatus.fromLabel(map['status'] as String? ?? 'inactive'),
      stopReasons: map['stopReasons'] as String?,
      avatar: map['avatar'] as String?,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['lastModified'] as String?,
      qualification: map['qualification'] as String? ?? '',
      memorizationLevel: map['memorizationLevel'] as String? ?? '',
      // التعامل مع اختلاف نوع البيانات
      isDeleted: fromDb
          ? (map['isDeleted'] == 1)
          : (map['isDeleted'] as bool? ?? false),
    );
  }

  // دالة موحدة لإنشاء خريطة (للـ API والـ DB)
  Map<String, dynamic> toMap({bool forDb = false}) {
    return {
      'uuid': id,
      'roleId': UserRole.student.id,
      'name': name,
      'gender': gender.id,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
      'phoneZone': phoneZone,
      if (forDb) 'whatsapp': whatsappPhone else 'whatsappPhone': whatsappPhone,
      'whatsappZone': whatsappZone,
      'bio': bio,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'country': country,
      'residence': residence,
      'city': city,
      'availableTime': availableTime,
      'status': status.label,
      'stopReasons': stopReasons,
      'avatar': avatar,
      'memorizationLevel': memorizationLevel,
      'createdAt':
          DateTime.tryParse(createdAt ?? "")?.toIso8601String() ??
          DateTime.now().toIso8601String(),

      'lastModified':
          DateTime.tryParse(updatedAt ?? "")?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'isDeleted': forDb ? (isDeleted ? 1 : 0) : isDeleted,
    };
  }

  /// Converts this data model into a lightweight [StudentListItemEntity].
  StudentListItemEntity toListItemEntity() {
    return StudentListItemEntity(
      id: id,
      name: name,
      gender: gender,
      country: country,
      city: city,
      avatar: avatar ?? '',
      stopReasons: stopReasons,
      status: status,
    );
  }

  /// Converts this data model into a detailed [StudentDetailEntity].
  StudentDetailEntity toDetailEntity() {
    final timeParts = (availableTime ?? '00:00').split(':');
    return StudentDetailEntity(
      id: id,
      name: name,
      avatar: avatar ?? '',
      status: status,
      gender: gender,
      birthDate: birthDate,
      email: email,
      phone: phone,
      phoneZone: int.tryParse(phoneZone ?? '0') ?? 0,
      whatsAppPhone: whatsappPhone ?? '',
      whatsAppZone: int.tryParse(whatsappZone ?? '0') ?? 0,
      qualification: qualification,
      experienceYears: experienceYears,
      country: country,
      residence: residence,
      city: city,
      availableTime: TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 0,
        minute: int.tryParse(timeParts[1]) ?? 0,
      ),
      memorizationLevel: memorizationLevel,
      stopReasons: stopReasons ?? '',
      bio: bio ?? '',
      createdAt: createdAt ?? '',
      updatedAt: updatedAt ?? '',
    ); // Convert to FollowUpPlanEntity    );
  }

  /// Converts this data model into a domain [StudentEntity].
  /// ///
  /// This method serves as the boundary between the data and domain layers,
  /// transforming the data-centric model into a pure business object.
  factory StudentModel.fromEntity(StudentDetailEntity student) {
    return StudentModel(
      id: student.id,
      name: student.name,
      gender: student.gender,
      birthDate: student.birthDate,
      email: student.email,
      phone: student.phone,
      experienceYears: student.experienceYears,
      country: student.country,
      residence: student.residence,
      city: student.city,
      status: student.status,
      qualification: student.qualification,
      memorizationLevel: student.memorizationLevel,
      isDeleted: false,
    );
  }

  // --- Boilerplate code for value equality ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

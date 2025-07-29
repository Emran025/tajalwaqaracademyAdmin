import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';

import '../../domain/entities/teacher_entity.dart';
import '../../domain/entities/teacher_list_item_entity.dart';
import 'assigned_halaqas_model.dart';

/// The data model for a Teacher, serving as the data transfer object (DTO)
/// for the data layer. It is a plain, immutable Dart object.
///
/// This single model is capable of representing the full teacher data and can be
/// transformed into either a lightweight [TeacherListItemEntity] for lists or a
/// complete [TeacherDetailEntity] for profile views.
@immutable
final class TeacherModel {
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
  final String? createdAt;
  final String? updatedAt;
  final String qualification;
  final bool isDeleted;
  final List<AssignedHalaqasModel> assignedHalaqas;

  const TeacherModel({
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
    required this.qualification,
    required this.isDeleted,
    this.assignedHalaqas = const [],
  });

  // /// Creates a [TeacherModel] from a JSON map received from an API.
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the nested list of halqas.
    final halqasListJson = json['assignedHalaqas'] as List<dynamic>? ?? [];
    final halqas = halqasListJson
        .map((halaqaJson) => AssignedHalaqasModel.fromJson(halaqaJson as Map<String, dynamic>))
        .toList();


    return TeacherModel(
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
      qualification: json['qualification'] as String? ?? '',
      isDeleted: json['isDeleted'] as bool? ?? false,
      assignedHalaqas: halqas,
    );
  }

  /// Creates a [TeacherModel] from a JSON map received from an API.
  factory TeacherModel.fromDbMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['uuid'] as String? ?? (map['id'] as int? ?? 0).toString(),
      name: map['name'] as String? ?? 'Unknown Name',
      gender: Gender.fromLabel(
        map['gender'] as String? ?? Gender.male.labelAr.toLowerCase(),
      ),
      birthDate: map['birthDate'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      phoneZone: map['phoneZone'] as String?,
      whatsappPhone: map['whatsapp'] as String?,
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
      updatedAt: map['updatedAt'] as String?,
      qualification: map['qualification'] as String? ?? '',
      isDeleted:
          (map['isDeleted'] as int) == 1, // Convert integer back to boolean
    );
  }

  /// Converts this data model into a lightweight [TeacherListItemEntity].
  TeacherListItemEntity toListItemEntity() {
    return TeacherListItemEntity(
      id: id,
      name: name,
      gender: gender,
      country: country,
      city: city,
      avatar: avatar ?? '',
      status: status,
    );
  }

  /// Converts this data model into a detailed [TeacherDetailEntity].
  TeacherDetailEntity toDetailEntity() {
    final timeParts = (availableTime ?? '00:00').split(':');
    return TeacherDetailEntity(
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
      stopReasons: stopReasons ?? '',
      bio: bio ?? '',
      createdAt: createdAt ?? '',
      updatedAt: updatedAt ?? '',
      halqas: const [],
    );
  }

  /// Converts the [TeacherModel] to a database map.
  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'roleId': UserRole.teacher.id,
      'name': name,
      'gender': gender.labelAr,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
      'phoneZone': phoneZone,
      'whatsappPhone': whatsappPhone,
      'whatsappZone': whatsappZone,
      'bio': bio,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'country': country,
      'residence': residence,
      'city': city,
      'availableTime': availableTime,
      'status': status.labelAr,
      'stopReasons': stopReasons,
      'avatar': avatar,
      'memorizationLevel': null,
      'lastModified': DateTime.parse(
        updatedAt ?? "${DateTime.now()}",
      ).millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'uuid': id,
      'roleId': UserRole.teacher.id,
      'name': name,
      'gender': gender.labelAr,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
      'phoneZone': phoneZone,
      'whatsapp': whatsappPhone,
      'whatsappZone': whatsappZone,
      'bio': bio,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'country': country,
      'residence': residence,
      'city': city,
      'availableTime': availableTime,
      'status': status.labelAr,
      'stopReasons': stopReasons,
      'avatar': avatar,
      'memorizationLevel': null,
      'lastModified': DateTime.parse(
        updatedAt ?? "${DateTime.now()}",
      ).millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  /// Converts this data model into a domain [TeacherEntity].
  /// ///
  /// This method serves as the boundary between the data and domain layers,
  /// transforming the data-centric model into a pure business object.
  factory TeacherModel.fromEntity(TeacherDetailEntity teacher) {
    return TeacherModel(
      id: teacher.id,
      name: teacher.name,
      gender: teacher.gender,
      birthDate: teacher.birthDate,
      email: teacher.email,
      phone: teacher.phone,
      experienceYears: teacher.experienceYears,
      country: teacher.country,
      residence: teacher.residence,
      city: teacher.city,
      status: teacher.status,
      qualification: teacher.qualification,
      isDeleted: false,
    );
  }

  // --- Boilerplate code for value equality ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

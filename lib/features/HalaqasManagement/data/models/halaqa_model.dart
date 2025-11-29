import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';

import '../../domain/entities/halaqa_entity.dart';
import '../../domain/entities/halaqa_list_item_entity.dart';

/// The data model for a Halaqa, serving as the data transfer object (DTO)
/// for the data layer. It is a plain, immutable Dart object.
///
/// This single model is capable of representing the full halaqa data and can be
/// transformed into either a lightweight [HalaqaListItemEntity] for lists or a
/// complete [HalaqaDetailEntity] for profile views.
@immutable
final class HalaqaModel {
  final String id; // The UUID string
  final String name;
  final String? avatar;
  final Gender gender;
  final String country;
  final String residence;
  final int sumOfStudents;
  final int maxOfStudents;
  final String? availableTime;
  final ActiveStatus status;
  final String? createdAt;
  final String? updatedAt;
  final bool isDeleted;
  final int teacherId;

  const HalaqaModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.country,
    required this.residence,
    required this.sumOfStudents,
    required this.maxOfStudents,

    this.availableTime,
    required this.status,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    required this.teacherId,
  });

  // /// Creates a [HalaqaModel] from a JSON map received from an API.
  factory HalaqaModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the nested list of halqas.

    return HalaqaModel(
      id: (json['id'] as int? ?? 0).toString(),
      name: json['name'] as String? ?? 'Unknown Name',
      gender: Gender.fromLabel(
        json['gender'] as String? ?? Gender.male.labelAr.toLowerCase(),
      ),

      country: json['country'] as String? ?? 'اليمن',
      residence: json['residence'] as String? ?? '',

      availableTime: json['availableTime'] as String?,
      status: ActiveStatus.fromId(json['isActive'] as int? ?? 2),
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isDeleted: (json['isDeleted'] as int) == 1,
      teacherId: json['teacherId'] as int? ?? 0,
      sumOfStudents: json['sumOfStudents'] as int? ?? 0,
      maxOfStudents: json['maxOfStudents'] as int? ?? 0,
    );
  }

  /// Creates a [HalaqaModel] from a JSON map received from an API.
  factory HalaqaModel.fromMap(Map<String, dynamic> map) {
    return HalaqaModel(
      id: map['uuid'] as String? ?? (map['id'] as int? ?? 0).toString(), //
      name: map['name'] as String? ?? 'Unknown Name', //
      gender: Gender.fromId(map['gender'] as int? ?? Gender.male.id), //
      country: map['country'] as String? ?? '', //
      residence: map['residence'] as String? ?? '', //
      availableTime: map['availableTime'] as String?, //
      status: ActiveStatus.fromId(map['isActive'] as int? ?? 2), //

      createdAt: map['createdAt'] as String?,
      updatedAt: map['lastModified'] as String?,

      isDeleted: (map['isDeleted'] as int) == 1, //
      teacherId: map['teacherId'] as int? ?? 0,
      sumOfStudents: map['sumOfStudents'] as int? ?? 0, //
      maxOfStudents: map['maxOfStudents'] as int? ?? 0, //
    );
  }

  /// Converts this data model into a lightweight [HalaqaListItemEntity].
  HalaqaListItemEntity toListItemEntity() {
    return HalaqaListItemEntity(
      id: id,
      name: name,
      gender: gender,
      country: country,
      residence: residence,
      avatar: avatar ?? '',
      status: status,
    );
  }

  /// Converts this data model into a detailed [HalaqaDetailEntity].
  HalaqaDetailEntity toDetailEntity() {
    return HalaqaDetailEntity(
      id: id,
      name: name,
      avatar: avatar ?? '',
      status: status,
      gender: gender,
      country: country,
      residence: residence,
      createdAt: createdAt ?? '',
      updatedAt: updatedAt ?? '',
      teacherId: teacherId,
      sumOfStudents: sumOfStudents,
      maxOfStudents: maxOfStudents,
    );
  }

  /// Converts the [HalaqaModel] to a database map.
  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      // 'memorizationLevel': null,
      'uuid': id,
      'name': name,
      'gender': gender.id,
      'country': country,
      'residence': residence,
      'availableTime': availableTime,
      'status': status.labelAr,
      'avatar': avatar,
      'createdAt':
          DateTime.tryParse(createdAt ?? "")?.toIso8601String() ??
          DateTime.now().toIso8601String(),

      'lastModified':
          DateTime.tryParse(updatedAt ?? "")?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'isDeleted': isDeleted,
      'sumOfStudents': sumOfStudents,
      'maxOfStudents': maxOfStudents,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': id,
      'name': name,
      'isActive': status.id,
      // 'teacherId': teacherId,
      'sumOfStudents': sumOfStudents,
      'maxOfStudents': maxOfStudents,
      'availableTime': availableTime,
      'country': country,
      'residence': residence,
      'gender': gender.id,
      'createdAt':
          DateTime.tryParse(createdAt ?? "")?.toIso8601String() ??
          DateTime.now().toIso8601String(),

      'lastModified':
          DateTime.tryParse(updatedAt ?? "")?.toIso8601String() ??
          DateTime.now().toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  /// Converts this data model into a domain [HalaqaEntity].
  /// ///
  /// This method serves as the boundary between the data and domain layers,
  /// transforming the data-centric model into a pure business object.
  factory HalaqaModel.fromEntity(HalaqaDetailEntity halaqa) {
    return HalaqaModel(
      id: halaqa.id,
      name: halaqa.name,
      gender: halaqa.gender,
      country: halaqa.country,
      residence: halaqa.residence,
      sumOfStudents: halaqa.sumOfStudents,
      maxOfStudents: halaqa.maxOfStudents,
      status: halaqa.status,
      createdAt: halaqa.createdAt,
      updatedAt: halaqa.updatedAt,
      isDeleted: false,
      teacherId: halaqa.teacherId,
    );
  }

  // --- Boilerplate code for value equality ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HalaqaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

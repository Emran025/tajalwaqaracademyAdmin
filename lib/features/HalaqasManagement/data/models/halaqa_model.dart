import 'package:flutter/material.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';
import 'package:tajalwaqaracademy/core/models/gender.dart';
import 'package:tajalwaqaracademy/core/models/user_role.dart';

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
  final Gender gender;
  final String country;
  final String residence;
  final String city;
  final String? availableTime;
  final ActiveStatus status;
  final String? avatar;
  final String? createdAt;
  final String? updatedAt;
  final bool isDeleted;
  final  String teacher;

  const HalaqaModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.country,
    required this.residence,
    required this.city,
    this.availableTime,
    required this.status,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    required this.isDeleted,
    required this.teacher,
  });

  // /// Creates a [HalaqaModel] from a JSON map received from an API.
  factory HalaqaModel.fromJson(Map<String, dynamic> json) {
    // Safely parse the nested list of halqas.

    return HalaqaModel(
      id: json['uuid'] as String? ?? (json['id'] as int? ?? 0).toString(),
      name: json['name'] as String? ?? 'Unknown Name',
      gender: Gender.fromLabel(
        json['gender'] as String? ?? Gender.male.labelAr.toLowerCase(),
      ),
      country: json['country'] as String? ?? '',
      residence: json['residence'] as String? ?? '',
      city: json['city'] as String? ?? '',
      availableTime: json['availableTime'] as String?,
      status: ActiveStatus.fromLabel(json['status'] as String? ?? 'inactive'),
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      teacher:  json['teacherId'] as String? ?? '0',
    );
  }

  /// Creates a [HalaqaModel] from a JSON map received from an API.
  factory HalaqaModel.fromDbMap(Map<String, dynamic> map) {
    return HalaqaModel(
      id: map['uuid'] as String? ?? (map['id'] as int? ?? 0).toString(),
      name: map['name'] as String? ?? 'Unknown Name',
      gender: Gender.fromLabel(
        map['gender'] as String? ?? Gender.male.labelAr.toLowerCase(),
      ),
      country: map['country'] as String? ?? '',
      residence: map['residence'] as String? ?? '',
      city: map['city'] as String? ?? '',
      availableTime: map['availableTime'] as String?,
      status: ActiveStatus.fromLabel(map['status'] as String? ?? 'inactive'),
      avatar: map['avatar'] as String?,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
      isDeleted:
          (map['isDeleted'] as int) == 1, // Convert integer back to boolean
                teacher:  map['teacherId'] as String? ?? '',

    );
  }

  /// Converts this data model into a lightweight [HalaqaListItemEntity].
  HalaqaListItemEntity toListItemEntity() {
    return HalaqaListItemEntity(
      id: id,
      name: name,
      gender: gender,
      country: country,
      city: city,
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
      city: city,
            createdAt: createdAt ?? '',
      updatedAt: updatedAt ?? '',
      teacher: teacher,

    );
  }

  /// Converts the [HalaqaModel] to a database map.
  Map<String, dynamic> toJson() {
    return {
      'uuid': id,
      'roleId': UserRole.halaqa.id,
      'name': name,
      'gender': gender.labelAr,
      'country': country,
      'residence': residence,
      'city': city,
      'availableTime': availableTime,
      'status': status.labelAr,
      'avatar': avatar,
      'memorizationLevel': null,
      'lastModified': DateTime.parse(
        updatedAt ?? "${DateTime.now()}",
      ).millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'teacherId' : teacher
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'uuid': id,
      'roleId': UserRole.halaqa.id,
      'name': name,
      'gender': gender.labelAr,
      'country': country,
      'residence': residence,
      'city': city,
      'availableTime': availableTime,
      'status': status.labelAr,
      'avatar': avatar,
      'memorizationLevel': null,
      'lastModified': DateTime.parse(
        updatedAt ?? "${DateTime.now()}",
      ).millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
            'teacherId' : teacher

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
      city: halaqa.city,
      status: halaqa.status,
      createdAt: halaqa.createdAt,
      updatedAt: halaqa.updatedAt,
      isDeleted: false,
      teacher: halaqa.teacher,
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

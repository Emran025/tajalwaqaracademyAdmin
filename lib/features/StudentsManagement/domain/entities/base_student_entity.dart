// import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:tajalwaqaracademy/core/models/active_status.dart';

import '../../../../core/models/gender.dart';

/// The base abstract entity for a Student.
///
/// It contains the core properties shared between the list view and the
/// detailed view. Using [Equatable] for value-based equality.
abstract class BaseStudentEntity  {
  final String id;
  final String name;
  final Gender gender;
  final String country;
  final String city;
  final String avatar;
  final ActiveStatus status;

  const BaseStudentEntity({
    required this.id,
    required this.name,
    required this.gender,
    required this.country,
    required this.city,
    required this.avatar,
    required this.status,
  });

}

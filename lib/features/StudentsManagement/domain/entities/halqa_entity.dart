
import 'package:flutter/foundation.dart';

@immutable
class AssignedHalaqasEntity {
  final String id;
  final String name;
  final String avatar;

  const AssignedHalaqasEntity({required this.id, required this.name, required this.avatar});
  const AssignedHalaqasEntity.empty()
      : id = '0',
        name = 'النور',
        avatar = 'assets/images/logo2.png';
}
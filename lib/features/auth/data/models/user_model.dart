


import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.roleId,
    required super.status,
    required super.name,
    required super.gender,
    required super.email,
    required super.phone,
    super.birthDate,
    super.avatar,
    super.phoneZone,
    super.whatsappZone,
    super.whatsapp,
    super.qualification,
    super.experienceYears,
    super.country,
    super.residence,
    super.city,
    super.availableTime,
    super.stopReasons,
    super.memorizationLevel,
  });

  /// Factory constructor لإنشاء نسخة UserModel من JSON القادم من الـ API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      roleId: json['role_id'],
      status: json['status'],
      name: json['name'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      email: json['email'],
      avatar: json['profile_picture_url'],
      phoneZone: json['phone_zone'],
      phone: json['phone'],
      whatsappZone: json['whatsapp_zone'],
      whatsapp: json['whatsapp_phone'],
      qualification: json['qualification'],
      // التأكد من أن القيمة من نوع int
      experienceYears: json['experience_years'] is String
          ? int.tryParse(json['experience_years'])
          : json['experience_years'],
      country: json['country'],
      residence: json['residence'],
      city: json['city'],
      availableTime: json['available_time'],
      stopReasons: json['stop_reasons'],
      memorizationLevel: json['memorization_level'],
    );
  }

  /// Factory constructor لإنشاء نسخة UserModel من Map قادم من قاعدة البيانات المحلية
  factory UserModel.fromDbMap(Map<String, dynamic> map) {
    return UserModel(
      // لاحظ أن أسماء الأعمدة في قاعدة البيانات المحلية تختلف (camelCase)
      id: map['id'],
      roleId: map['roleId'],
      status: map['status'],
      name: map['name'],
      gender: map['gender'],
      birthDate: map['birthDate'],
      email: map['email'],
      avatar: map['avatar'],
      phoneZone: map['phoneZone'],
      phone: map['phone'],
      whatsappZone: map['whatsappZone'],
      whatsapp: map['whatsapp'],
      qualification: map['qualification'],
      experienceYears: map['experienceYears'],
      country: map['country'],
      residence: map['residence'],
      city: map['city'],
      availableTime: map['availableTime'],
      stopReasons: map['stopReasons'],
      memorizationLevel: map['memorizationLevel'],
    );
  }

  /// دالة لتحويل UserModel إلى Map لتخزينه في قاعدة البيانات المحلية
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'status': status,
      'name': name,
      'gender': gender,
      'birthDate': birthDate,
      'email': email,
      'avatar': avatar,
      'phoneZone': phoneZone,
      'phone': phone,
      'whatsappZone': whatsappZone,
      'whatsapp': whatsapp,
      'qualification': qualification,
      'experienceYears': experienceYears,
      'country': country,
      'residence': residence,
      'city': city,
      'availableTime': availableTime,
      'stopReasons': stopReasons,
      'memorizationLevel': memorizationLevel,
      // الحقول الإضافية في جدول قاعدة البيانات
      // 'uuid' يمكن إنشاؤه هنا إذا لم يكن موجودًا
      'lastModified': DateTime.now().millisecondsSinceEpoch,
      'isDeleted': 0, // القيمة الافتراضية عند الحفظ
    };
  }

  UserEntity toUserEntity() {
    return UserEntity(
      id: id,
      roleId: roleId,
      status: status,
      name: name,
      gender: gender,
      email: email,
      phone: phone,
      birthDate: birthDate,
      avatar: avatar,
      phoneZone: phoneZone,
      whatsappZone: whatsappZone,
      whatsapp: whatsapp,
      qualification: qualification,
      experienceYears: experienceYears,
      country: country,
      residence: residence,
      city: city,
      availableTime: availableTime,
      stopReasons: stopReasons,
      memorizationLevel: memorizationLevel,
    );
  }
}

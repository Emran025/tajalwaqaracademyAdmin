class ConstantsKeys {
  static const String baseUrl =
      "http://192.168.124.7/tag-al-waqar/public/api/v1/";
}

abstract class ConstantsKey {
  final String endPoint;
  ConstantsKey({required this.endPoint});
}

class ApiKey {
  static String id = 'id';
  static String logIn = 'login';
  static String email = 'email';
  static String password = 'password';
  static String oldPassword = 'Oldpassword';
  static String verificationCode = 'VerificationCode';
  static String code = 'code';
  static String role = 'role';
  static String name = 'name';
  static String profileImagePath = 'profileImagePath';
  static String gender = 'gender';
  static String birthDate = 'birthDate';
  static String birthContery = 'birthContery';
  static String birthStates = 'birthStates';
  static String birthCity = 'birthCity';
  static String nationality = 'nationality';

  static String phoneNumber = 'phoneNumber';
  static String whatsappNumber = 'whatsappNumber';
  static String currentAddress = 'currentAddress';
  static String nameOfRelative = 'nameOfRelative';

  static String status = "status";
  static String message = "message";

  static String countryId = "countryId";
  static String isActive = "isActive";
  static String token = "token";
  static String confirmPassword = "confirmPassword";
  static String location = "location";

  static String roleId = 'roleId';
  static String firstName = 'firstName';
  static String lastName = 'lastName';
  static String phone = 'phone';

  static const String teacherID = 'teacher_id';

  static const String phoneZone = 'phone_zone';
  static const String whatsAppPhone = 'whats_app_phone';
  static const String whatsAppZone = 'whats_app_zone';
  static const String qualification = 'qualification';
  static const String experienceYears = 'experience_years';
  static const String country = 'country';
  static const String residence = 'residence';
  static const String city = 'city';
  static const String availableTime = 'available_time';
  static const String stopReasons = 'stop_reasons';
  static const String pic = 'pic';
  static const String halqas = 'halqas';
}

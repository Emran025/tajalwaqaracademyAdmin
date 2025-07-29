class EndPoint {
  static const String baseUrl =
      // "http://192.168.237.92/tajalwaqaracademy/"; //192.168.251.92//192.168.43.92//192.168.43.89
      // "http://192.168.43.92/tajalwaqaracademy/"; //192.168.251.92//192.168.43.92//192.168.43.89
      // "http://192.168.43.92/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
      // "http://localhost/tag-al-waqar/public/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
      "http://192.168.43.92/tag-al-waqar/public/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
  // "http://0.0.0.0:8000/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
  // "http://127.0.0.1:8000/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
  // "http://127.0.0.1:8000/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
  // "https://taj-al-waqar.saherqaid.com/api/v1/"; //192.168.251.92//192.168.43.92//192.168.43.89
  static const String login = "package/auth/login.php";
  static const String refreshToken = "refreshToken";
  static const String teachers = "teachers";
  static const String students = "teachers";
  static const String teachersSync = "sync/teachers";
  static const String studentsSync = "sync/students";
  static const String teachersUpsert = "teachersUpsert";
  static const String studentsUpsert = "studentsUpsert";
  static const String fristSignUp = "package/auth/register.php";
  static const String signUp = "package/auth/complateRegistration.php";
  static const String verifyCode = "package/auth/verifyCode.php";
  static const String forgetPassword = "package/auth/forgetPass.php";
  static const String newPassword = "package/auth/resetPass.php";
  static const String counteris = "getCounteries/Counteries.php";
  static const String states = "getStates/States.php";
  static const String cities = "getCities/Cities.php";

  static String getUserDataEndPoint(id) {
    return "user/get-user/$id";
  }
}

class ApiKey {
  static String id = 'id';
  static String login = 'login';
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

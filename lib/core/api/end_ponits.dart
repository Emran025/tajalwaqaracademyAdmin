class EndPoint {
  static const String baseUrl =
      "http://192.168.124.7/tag-al-waqar/public/api/v1/"; //192.168.32.92

  /// Endpoint for fetching a specific student's follow-up tracking records.
  /// The `{id}` placeholder will be replaced by the student's actual ID.
  static const String studentTrackings = '/students/{id}/trackings';
  static const String logIn = "auth/login";
  static const String forgetPassword = "auth/forgot-password";
  static const String logOut = "auth/logout";
  static const String refreshToken = "refreshToken";
  static const String userProfile = "account/profile";
  static const String changePassword = "account/change-password";
  static const String sessions = "account/sessions";
  static const String studentApplicants =
      "admin/applicants?application_type={application_type}";
  static const String applicantProfile = "admin/applicants/{id}";
  static const String approveApplicant = "admin/applicants/{id}/approve";
  static const String rejectApplicant = "admin/applicants/{id}/reject";
  static const String privacyPolicy = "help/privacy-policy";
  static const String faqs = "help/faqs";
  static const String tickets = "help/tickets";
  static const String termsOfUse = "help/terms-of-use";
  static const String teachers = "teachers";
  static const String students = "students";
  static const String halaqas = "halaqas";
  static const String teachersSync = "sync/teachers";
  static const String studentsSync = "sync/students";
  static const String halaqasSync = "sync/halaqas";
  static const String trackingsSync = "sync/trackings";
  static const String teachersUpsert = "teachers/{id}";
  static const String studentsUpsert = "students/{id}";
  static const String halaqasUpsert = "halaqas/{id}";

  static String getUserDataEndPoint(id) {
    return "user/get-user/$id";
  }
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

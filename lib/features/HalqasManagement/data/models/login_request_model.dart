class LoginRequestModel {
  final String email;
  final String password;
  final String phone;

  LoginRequestModel({
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": password,
    "phone": phone,
  };
  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      email: json["email"],
      password: json["password"],
      phone: json["phone"],
    );
  }
}
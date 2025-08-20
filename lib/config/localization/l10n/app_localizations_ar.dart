// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أكاديمية تاج الوقار';

  @override
  String get logInButton => 'تسجيل الدخول';

  @override
  String get emailHint => 'البريد الإلكتروني';

  @override
  String welcomeMessage(String userName) {
    return 'مرحباً بك، $userName!';
  }
}

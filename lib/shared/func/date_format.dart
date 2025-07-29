import 'package:intl/intl.dart' show DateFormat;


  String formatDate(DateTime dt) {
    // d   => يوم (1 or 2 digits)
    // MMMM => اسم الشهر كامل
    // y   => السنة
    return DateFormat('d MMMM y', 'ar').format(dt);
  }

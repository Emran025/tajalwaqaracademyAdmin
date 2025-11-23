// lib/core/utils/app_strings.dart

/// A centralized class for managing all user-facing strings in the application.
///
/// This approach is crucial for maintainability and future localization.
/// Instead of hardcoding text in widgets, we use constants from this class.
///
/// Usage:
/// - Text(AppStrings.appName)
/// - AppBar(title: Text(AppStrings.bookmarksTitle))
class AppStrings {
  // Make the class non-instantiable.
  AppStrings._();

  // --- General & App-wide Strings ---
  static const String ok = 'موافق';
  static const String cancel = 'إلغاء';
  static const String error = 'خطأ';
  static const String success = 'نجاح';
  static const String loading = 'جار التحميل...';
  
  // --- Quran Reader Screen ---
  static const String juz = 'الجزء';
  static const String page = 'صفحة';
  static const String surah = 'سورة';
  static const String ayah = 'آية';
  
  // --- Reader Menu & Dialogs ---
  static const String settings = 'الإعدادات';
  static const String bookmarks = 'المحفوظات';
  static const String theme = 'المظهر';
  static const String copy = 'نسخ';
  static const String share = 'مشاركة';
  static const String addToBookmarks = 'إضافة للمحفوظات';
  static const String removeFromBookmarks = 'إزالة من المحفوظات';
  static const String copySuccessMessage = 'تم نسخ الآية بنجاح';

  // --- Bookmarks Screen ---
  static const String bookmarksTitle = 'المحفوظات';
  static const String bookmarkedPages = 'الصفحات';
  static const String bookmarkedAyahs = 'الآيات';
  static const String noBookmarksFound = 'لم يتم العثور على محفوظات.';
  static const String confirmDeleteBookmarkTitle = 'تأكيد الحذف';
  static String confirmDeleteBookmarkMessage(String type) => 'هل أنت متأكد من حذف هذه العلامة المرجعية من $type؟';


  // --- Settings Screen ---
  static const String settingsTitle = 'الإعدادات';
  static const String themeSettings = 'إعدادات المظهر';
  static const String lightTheme = 'فاتح';
  static const String darkTheme = 'داكن';
  static const String readingTheme = 'القراءة';

  // --- Error Messages ---
  static const String defaultErrorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  static const String networkErrorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك.';
  static const String dataLoadErrorMessage = 'حدث خطأ أثناء تحميل البيانات.';
  static const List<JuzsListEntity> juzsList = [
      
 

// INSERT INTO TrackingUnit (id, from_page, from_ayah, to_page, to_ayah) VALUES
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلْأَوَّلُ',
1, 1, 1, 21, 148),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلثَّانِي',
2, 22, 149, 41, 259),
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلثَّالِثُ',
3, 42, 260, 62, 385),
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلرَّابِعُ',

4, 62, 386, 81, 516),
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلْخَامِسُ',
5, 82, 517, 101, 640),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلسَّادِسُ',
6, 102, 641, 121, 750),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلسَّابِعُ',

7, 121, 751, 141, 899),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلثَّامِنُ',

8, 142, 900, 161, 1041),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلتَّاسِعُ',
9, 162, 1042, 181, 1200),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلْعَاشِرُ',
10, 182, 1201, 201, 1327),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلْحَادِي عَشَرَ',
11, 201, 1328, 221, 1478),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلثَّانِي عَشَرَ',
12, 222, 1479, 241, 1648),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلثَّالِثُ عَشَرَ',
13, 242, 1649, 261, 1802),
  JuzsListEntity(

  'ٱلْجُزْءُ ٱلرَّابِعُ عَشَرَ',
14, 262, 1803, 281, 2029),
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلْخَامِسُ عَشَرَ',
15, 282, 2030, 301, 2214),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلسَّادِسُ عَشَرَ',
16, 302, 2215, 321, 2483),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلسَّابِعُ عَشَرَ',
17, 322, 2484, 341, 2673),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلثَّامِنُ عَشَرَ',
18, 342, 2674, 361, 2875),
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلتَّاسِعُ عَشَرَ',
19, 362, 2876, 381, 3214),
  JuzsListEntity(

  'ٱلْجُزْءُ ٱلْعِشْرُونَ',
20, 382, 3215, 401, 3385),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلْحَادِي وَٱلْعِشْرُونَ',
21, 402, 3386, 421, 3563),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلثَّانِي وَٱلْعِشْرُونَ',
22, 422, 3564, 441, 3732),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلثَّالِثُ وَٱلْعِشْرُونَ',
23, 442, 3733, 461, 4089),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلرَّابِعُ وَٱلْعِشْرُونَ',
24, 462, 4090, 481, 4264),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلْخَامِسُ وَٱلْعِشْرُونَ',
25, 482, 4265, 502, 4510),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلسَّادِسُ وَٱلْعِشْرُونَ',
26, 502, 4511, 521, 4705),
  JuzsListEntity(

      'ٱلْجُزْءُ ٱلسَّابِعُ وَٱلْعِشْرُونَ',
27, 522, 4706, 541, 5104),
  JuzsListEntity(

     'ٱلْجُزْءُ ٱلثَّامِنُ وَٱلْعِشْرُونَ',
28, 542, 5105, 561, 5241),
  JuzsListEntity(

    'ٱلْجُزْءُ ٱلتَّاسِعُ وَٱلْعِشْرُونَ',
29, 562, 5242, 581, 5672),


  JuzsListEntity(

      'ٱلْجُزْءُ ٱلثَّلَاثُونَ',
30, 582, 5673, 604, 6236),

];


}

class JuzsListEntity {
final int id; final String juzName ;  final int fromPage;final int fromAyah;final int  toPage;final int toAyah;
  const JuzsListEntity( 
     this.juzName,
     this.
    id,this. fromPage, this.fromAyah,this. toPage,this. toAyah

  );
}






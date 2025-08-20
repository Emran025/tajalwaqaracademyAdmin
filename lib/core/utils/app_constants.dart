// lib/core/utils/app_constants.dart

/// A centralized class for application-wide constant values.
///
/// This class should only contain values that are known at compile-time and
/// do not change during the app's execution. It helps in avoiding "magic numbers"
/// or hardcoded strings in the codebase, making it more maintainable and less
/// prone to errors.
///
/// Usage:
/// - `AppConstants.db.bookmarksTable`
/// - `AppConstants.cache.themeKey`
class AppConstants {
  // Make the class non-instantiable.
  AppConstants._();

  /// Constants related to the SQLite database.
  static const DatabaseConstants db = DatabaseConstants();

  /// Constants for keys used in SharedPreferences (local cache).
  static const CacheConstants cache = CacheConstants();

  /// Constants for animations and transitions.
  static const AnimationConstants animation = AnimationConstants();
}

/// Holds constant values related to the local SQLite database,
/// such as table and column names.
class DatabaseConstants {
  const DatabaseConstants();

  // --- Database Filename ---
  String get databaseName => 'quran_app.db';

  // --- Table Names ---
  String get pageBookmarksTable => 'page_bookmarks';
  String get ayahBookmarksTable => 'ayah_bookmarks';
  // Future tables can be added here, e.g., 'notes', 'user_settings'

  // --- Common Column Names ---
  String get colId => 'id';
  String get colCreatedAt => 'created_at';
  
  // --- Page Bookmarks Columns ---
  String get colPageNum => 'page_number';
  String get colSurahName => 'surah_name';

  // --- Ayah Bookmarks Columns ---
  String get colSurahNumber => 'surah_number';
  String get colAyahNumber => 'ayah_number';
  String get colAyahUQNumber => 'ayah_uq_number'; // Unique number across the entire Quran
}

/// Holds keys for data stored in `SharedPreferences`.
class CacheConstants {
  const CacheConstants();

  String get themeKey => 'app_theme_type';
  String get lastReadPageKey => 'last_read_page';
  String get hasCopiedDbKey => 'has_copied_quran_db';
}

/// Holds constant values for animations, such as durations.
class AnimationConstants {
  const AnimationConstants();
  
  Duration get defaultDuration => const Duration(milliseconds: 300);
  Duration get longDuration => const Duration(milliseconds: 500);
}
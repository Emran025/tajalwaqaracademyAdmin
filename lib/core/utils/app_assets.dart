// lib/core/utils/app_assets.dart

/// A centralized class for managing asset paths.
///
/// This approach prevents hardcoding asset strings throughout the app,
/// making it easier to manage and update paths. It also reduces the risk of typos.
///
/// Usage:
/// - For SVG icons: `AppAssets.svg.bookmarkIcon`
/// - For Fonts: `AppAssets.fonts.quran`
/// - For JSON data: `AppAssets.jsonData.quranV2`
class AppAssets {
  // Base paths for different asset types.
  static const String _baseSvg = 'assets/svg';
  static const String _baseFonts = 'page';
  static const String _baseJson = 'assets/json';

  // Make the class non-instantiable.
  AppAssets._();

  /// Contains paths for all SVG assets.
  static const SvgAssets svg = SvgAssets();

  /// Contains identifiers for font families defined in pubspec.yaml.
  static const FontAssets fonts = FontAssets();

  /// Contains paths for all JSON data files.
  static const JsonAssets jsonData = JsonAssets();
}

/// A class holding paths to all SVG vector images.
class SvgAssets {
  const SvgAssets();

  // Common Icons
  String get besmAllah => '${AppAssets._baseSvg}/besmAllah.svg';
  String get besmAllah2 => '${AppAssets._baseSvg}/besmAllah2.svg';
  String get addBookmark => '${AppAssets._baseSvg}/bookmark_ic.svg';
  String get bookmarkIcon0 => '${AppAssets._baseSvg}/bookmark_icon.svg';
  String get bookmarkIcon2 => '${AppAssets._baseSvg}/bookmark_icon2.svg';
  String get bookmarkList => '${AppAssets._baseSvg}/bookmark_list.svg';
  String get copyIcon => '${AppAssets._baseSvg}/copy_icon.svg';
  String get decorations => '${AppAssets._baseSvg}/decorations.svg';
  String get options => '${AppAssets._baseSvg}/options.svg';
  String get sajdaIcon => '${AppAssets._baseSvg}/sajda_icon.svg';
  String get soraNum => '${AppAssets._baseSvg}/sora_num.svg';
  String get spaceLine => '${AppAssets._baseSvg}/space_line.svg';
  String get theme => '${AppAssets._baseSvg}/theme1.svg';
  String surahName(int surahNumber) => '${AppAssets._baseSvg}/surah_name/00$surahNumber.svg';

  // Banners
  String get surahAyahBanner1 => '${AppAssets._baseSvg}/surah_banner_ayah1.svg';
  String get surahAyahBanner2 => '${AppAssets._baseSvg}/surah_banner_ayah2.svg';
  String get surahBanner1 => '${AppAssets._baseSvg}/surah_banner1.svg';
  String get surahBanner2 => '${AppAssets._baseSvg}/surah_banner2.svg';
  String get surahBanner3 => '${AppAssets._baseSvg}/surah_banner3.svg';
  String get surahBanner4 => '${AppAssets._baseSvg}/surah_banner4.svg';
  String get circles => '${AppAssets._baseSvg}/circles.svg';
  String get dots => '${AppAssets._baseSvg}/dots.svg';
}

/// A class holding font family names.
/// These must match the `family` names defined in `pubspec.yaml`.
class FontAssets {
  const FontAssets();

  String get ios1 => 'ios-1';
  String get ios2 => 'ios-2';
  String get ios3 => 'ios-3';
  String get quran => 'quran';
  String get quran2 => 'quran2';
  String fontName(int pageNumber) => '${AppAssets._baseFonts}$pageNumber';


  // Add other font families here, e.g., 'uthmanic', 'kufi'
}

/// A class holding paths to JSON asset files.
class JsonAssets {
  const JsonAssets();

  String get quranV2 => '${AppAssets._baseJson}/quranV2.json';
  // The following JSON files from the old structure seem to be hardcoded lists.
  // It's better to manage them as part of a proper data source.
  // If they must remain as assets, they can be added here.
  // String get quranText => '${AppAssets._baseJson}/quran_text.json';
}

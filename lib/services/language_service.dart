import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage language preferences and first-time app launch
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _locationPermissionKey = 'location_permission_requested';

  /// Check if this is the first time the app is launched
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Mark that the app has been launched (not first time anymore)
  static Future<void> setNotFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  /// Get saved language code
  static Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  /// Save selected language code
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Check if location permission has been requested
  static Future<bool> hasRequestedLocationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionKey) ?? false;
  }

  /// Mark that location permission has been requested
  static Future<void> setLocationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionKey, true);
  }

  /// Get language based on country code
  static String getLanguageFromCountryCode(String countryCode) {
    final languageMap = {
      // English speaking countries
      'US': 'en', 'GB': 'en', 'CA': 'en', 'AU': 'en', 'NZ': 'en', 'IE': 'en',
      'ZA': 'en', 'NG': 'en', 'GH': 'en',

      // French speaking countries
      'FR': 'fr', 'BE': 'fr', 'CH': 'fr', 'LU': 'fr', 'MC': 'fr',
      'CD': 'fr', 'CI': 'fr', 'CM': 'fr', 'SN': 'fr', 'ML': 'fr',

      // German speaking countries
      'DE': 'de', 'AT': 'de', 'LI': 'de',

      // Spanish speaking countries
      'ES': 'es', 'MX': 'es', 'AR': 'es', 'CO': 'es', 'CL': 'es',
      'PE': 'es', 'VE': 'es', 'EC': 'es', 'GT': 'es', 'CU': 'es',
      'BO': 'es', 'DO': 'es', 'HN': 'es', 'PY': 'es', 'SV': 'es',
      'NI': 'es', 'CR': 'es', 'PA': 'es', 'UY': 'es',

      // Portuguese speaking countries
      'PT': 'pt', 'BR': 'pt', 'AO': 'pt', 'MZ': 'pt', 'GW': 'pt',

      // Swahili speaking countries
      'KE': 'sw', 'TZ': 'sw', 'UG': 'sw', 'RW': 'sw',

      // Arabic speaking countries
      'SA': 'ar', 'EG': 'ar', 'AE': 'ar', 'IQ': 'ar', 'MA': 'ar',
      'SD': 'ar', 'DZ': 'ar', 'SY': 'ar', 'YE': 'ar', 'JO': 'ar',
      'TN': 'ar', 'LY': 'ar', 'LB': 'ar', 'OM': 'ar', 'KW': 'ar',
      'QA': 'ar', 'BH': 'ar',

      // Chinese speaking countries/regions
      'CN': 'zh', 'TW': 'zh', 'HK': 'zh', 'SG': 'zh',

      // Hindi speaking country
      'IN': 'hi',

      // Japanese speaking country
      'JP': 'ja',
    };

    return languageMap[countryCode.toUpperCase()] ?? 'en';
  }

  /// Available languages with their display names and flags
  static List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
      {'code': 'fr', 'name': 'French', 'flag': '🇫🇷', 'native': 'Français'},
      {'code': 'de', 'name': 'German', 'flag': '🇩🇪', 'native': 'Deutsch'},
      {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸', 'native': 'Español'},
      {
        'code': 'pt',
        'name': 'Portuguese',
        'flag': '🇵🇹',
        'native': 'Português',
      },
      {'code': 'sw', 'name': 'Swahili', 'flag': '🇰🇪', 'native': 'Kiswahili'},
      {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇦', 'native': 'العربية'},
      {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳', 'native': '简体中文'},
      {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳', 'native': 'हिन्दी'},
      {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵', 'native': '日本語'},
    ];
  }
}

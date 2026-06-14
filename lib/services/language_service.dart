import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _locationPermissionKey = 'location_permission_requested';

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  static Future<void> setNotFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }

  static Future<String?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<bool> hasRequestedLocationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionKey) ?? false;
  }

  static Future<void> setLocationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionKey, true);
  }

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

      // Swahili speaking countries → fallback to English
      'KE': 'en', 'TZ': 'en', 'UG': 'en', 'RW': 'en',

      // Arabic speaking countries → fallback to English
      'SA': 'en', 'EG': 'en', 'AE': 'en', 'IQ': 'en', 'MA': 'en',
      'SD': 'en', 'DZ': 'en', 'SY': 'en', 'YE': 'en', 'JO': 'en',
      'TN': 'en', 'LY': 'en', 'LB': 'en', 'OM': 'en', 'KW': 'en',
      'QA': 'en', 'BH': 'en',

      // Chinese/Hindi/Japanese speaking countries → fallback to English
      'CN': 'en', 'TW': 'en', 'HK': 'en', 'SG': 'en',

      // Hindi speaking country
      'IN': 'en',

      // Japanese speaking country
      'JP': 'en',
    };

    return languageMap[countryCode.toUpperCase()] ?? 'en';
  }

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
    ];
  }
}

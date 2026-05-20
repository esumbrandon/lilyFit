import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lilyfit/services/language_service.dart';

void main() {
  group('LanguageService', () {
    group('getLanguageFromCountryCode', () {
      // English-speaking countries
      test(
        'maps US → en',
        () => expect(LanguageService.getLanguageFromCountryCode('US'), 'en'),
      );
      test(
        'maps GB → en',
        () => expect(LanguageService.getLanguageFromCountryCode('GB'), 'en'),
      );
      test(
        'maps CA → en',
        () => expect(LanguageService.getLanguageFromCountryCode('CA'), 'en'),
      );
      test(
        'maps AU → en',
        () => expect(LanguageService.getLanguageFromCountryCode('AU'), 'en'),
      );
      test(
        'maps NG → en',
        () => expect(LanguageService.getLanguageFromCountryCode('NG'), 'en'),
      );

      // French-speaking countries
      test(
        'maps FR → fr',
        () => expect(LanguageService.getLanguageFromCountryCode('FR'), 'fr'),
      );
      test(
        'maps BE → fr',
        () => expect(LanguageService.getLanguageFromCountryCode('BE'), 'fr'),
      );
      test(
        'maps SN → fr',
        () => expect(LanguageService.getLanguageFromCountryCode('SN'), 'fr'),
      );

      // German-speaking countries
      test(
        'maps DE → de',
        () => expect(LanguageService.getLanguageFromCountryCode('DE'), 'de'),
      );
      test(
        'maps AT → de',
        () => expect(LanguageService.getLanguageFromCountryCode('AT'), 'de'),
      );

      // Spanish-speaking countries
      test(
        'maps ES → es',
        () => expect(LanguageService.getLanguageFromCountryCode('ES'), 'es'),
      );
      test(
        'maps MX → es',
        () => expect(LanguageService.getLanguageFromCountryCode('MX'), 'es'),
      );
      test(
        'maps AR → es',
        () => expect(LanguageService.getLanguageFromCountryCode('AR'), 'es'),
      );
      test(
        'maps CO → es',
        () => expect(LanguageService.getLanguageFromCountryCode('CO'), 'es'),
      );

      // Portuguese-speaking countries
      test(
        'maps PT → pt',
        () => expect(LanguageService.getLanguageFromCountryCode('PT'), 'pt'),
      );
      test(
        'maps BR → pt',
        () => expect(LanguageService.getLanguageFromCountryCode('BR'), 'pt'),
      );

      // Swahili-speaking countries (fallback to English - not supported)
      test(
        'maps KE → en',
        () => expect(LanguageService.getLanguageFromCountryCode('KE'), 'en'),
      );
      test(
        'maps TZ → en',
        () => expect(LanguageService.getLanguageFromCountryCode('TZ'), 'en'),
      );
      test(
        'maps UG → en',
        () => expect(LanguageService.getLanguageFromCountryCode('UG'), 'en'),
      );

      // Arabic-speaking countries (fallback to English - not supported)
      test(
        'maps SA → en',
        () => expect(LanguageService.getLanguageFromCountryCode('SA'), 'en'),
      );
      test(
        'maps EG → en',
        () => expect(LanguageService.getLanguageFromCountryCode('EG'), 'en'),
      );
      test(
        'maps AE → en',
        () => expect(LanguageService.getLanguageFromCountryCode('AE'), 'en'),
      );

      // Chinese-speaking regions (fallback to English - not supported)
      test(
        'maps CN → en',
        () => expect(LanguageService.getLanguageFromCountryCode('CN'), 'en'),
      );
      test(
        'maps TW → en',
        () => expect(LanguageService.getLanguageFromCountryCode('TW'), 'en'),
      );
      test(
        'maps HK → en',
        () => expect(LanguageService.getLanguageFromCountryCode('HK'), 'en'),
      );

      // Hindi (fallback to English - not supported)
      test(
        'maps IN → en',
        () => expect(LanguageService.getLanguageFromCountryCode('IN'), 'en'),
      );

      // Japanese (fallback to English - not supported)
      test(
        'maps JP → en',
        () => expect(LanguageService.getLanguageFromCountryCode('JP'), 'en'),
      );

      // Case-insensitive lookup
      test('handles lowercase country code', () {
        expect(LanguageService.getLanguageFromCountryCode('us'), 'en');
        expect(LanguageService.getLanguageFromCountryCode('fr'), 'fr');
        expect(LanguageService.getLanguageFromCountryCode('de'), 'de');
      });

      test('handles mixed case country code', () {
        expect(LanguageService.getLanguageFromCountryCode('Us'), 'en');
      });

      // Unknown country code → defaults to English
      test('returns en for unknown country code', () {
        expect(LanguageService.getLanguageFromCountryCode('ZZ'), 'en');
        expect(LanguageService.getLanguageFromCountryCode('XX'), 'en');
      });
    });

    group('getAvailableLanguages', () {
      test('returns exactly 5 languages', () {
        expect(LanguageService.getAvailableLanguages().length, 5);
      });

      test('includes English', () {
        final langs = LanguageService.getAvailableLanguages();
        expect(langs.any((l) => l['code'] == 'en'), isTrue);
      });

      test('each language has code, name, flag, and native fields', () {
        for (final lang in LanguageService.getAvailableLanguages()) {
          expect(lang.containsKey('code'), isTrue, reason: 'Missing code');
          expect(lang.containsKey('name'), isTrue, reason: 'Missing name');
          expect(lang.containsKey('flag'), isTrue, reason: 'Missing flag');
          expect(lang.containsKey('native'), isTrue, reason: 'Missing native');
        }
      });

      test('includes all supported locale codes', () {
        final codes = LanguageService.getAvailableLanguages()
            .map((l) => l['code']!)
            .toList();
        for (final expected in ['en', 'fr', 'de', 'es', 'pt']) {
          expect(codes, contains(expected));
        }
      });
    });

    group('SharedPreferences-backed methods', () {
      setUp(() {
        SharedPreferences.setMockInitialValues({});
      });

      test('isFirstLaunch returns true on fresh install', () async {
        expect(await LanguageService.isFirstLaunch(), isTrue);
      });

      test('setNotFirstLaunch causes isFirstLaunch to return false', () async {
        await LanguageService.setNotFirstLaunch();
        expect(await LanguageService.isFirstLaunch(), isFalse);
      });

      test('getSavedLanguage returns null when no language is saved', () async {
        expect(await LanguageService.getSavedLanguage(), isNull);
      });

      test('saveLanguage persists and getSavedLanguage retrieves it', () async {
        await LanguageService.saveLanguage('fr');
        expect(await LanguageService.getSavedLanguage(), 'fr');
      });

      test('saveLanguage overwrites previous value', () async {
        await LanguageService.saveLanguage('es');
        await LanguageService.saveLanguage('de');
        expect(await LanguageService.getSavedLanguage(), 'de');
      });

      test('hasRequestedLocationPermission returns false by default', () async {
        expect(await LanguageService.hasRequestedLocationPermission(), isFalse);
      });

      test('setLocationPermissionRequested persists the flag', () async {
        await LanguageService.setLocationPermissionRequested();
        expect(await LanguageService.hasRequestedLocationPermission(), isTrue);
      });
    });
  });
}

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import "app_logger.dart";
import 'language_service.dart';

/// Service to get user location and detect appropriate language
class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    await LanguageService.setLocationPermissionRequested();
    return Geolocator.requestPermission();
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final bool serviceEnabled =
      await isLocationServiceEnabled();

      if (!serviceEnabled) {
        Applogger.w('Location services are disabled');
        return null;
      }

      // Check permission
      LocationPermission permission =
      await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();

        if (permission == LocationPermission.denied) {
          Applogger.w('Location permission denied');
          return null;
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        Applogger.w(
          'Location permission permanently denied',
        );

        return null;
      }

      const LocationSettings locationSettings =
      LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e, stackTrace) {
      Applogger.e(
        'Error getting location',
        e,
        stackTrace,
      );

      return null;
    }
  }

  /// Get country code from position
  static Future<String?> getCountryCodeFromPosition(
      Position position,
      ) async {
    try {
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }

      return null;
    } catch (e, stackTrace) {
      Applogger.e(
        'Error getting country from position',
        e,
        stackTrace,
      );

      return null;
    }
  }

  /// Detect language based on user's location
  static Future<String> detectLanguageFromLocation() async {
    try {
      final Position? position =
      await getCurrentPosition();

      if (position == null) {
        return 'en';
      }

      final String? countryCode =
      await getCountryCodeFromPosition(position);

      if (countryCode == null) {
        return 'en';
      }

      return LanguageService
          .getLanguageFromCountryCode(countryCode);
    } catch (e, stackTrace) {
      Applogger.e(
        'Error detecting language',
        e,
        stackTrace,
      );

      return 'en';
    }
  }

  /// Get suggested language with location info
  static Future<Map<String, dynamic>>
  getSuggestedLanguage() async {
    try {
      final Position? position =
      await getCurrentPosition();

      if (position == null) {
        return {
          'languageCode': 'en',
          'countryCode': null,
          'countryName': null,
          'locationAvailable': false,
        };
      }

      final List<Placemark> placemarks =
      await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark =
            placemarks.first;

        final String countryCode =
            placemark.isoCountryCode ?? 'US';

        final String languageCode =
        LanguageService
            .getLanguageFromCountryCode(
          countryCode,
        );

        return {
          'languageCode': languageCode,
          'countryCode': countryCode,
          'countryName': placemark.country,
          'locationAvailable': true,
        };
      }

      return {
        'languageCode': 'en',
        'countryCode': null,
        'countryName': null,
        'locationAvailable': false,
      };
    } catch (e, stackTrace) {
      Applogger.e(
        'Error getting suggested language',
        e,
        stackTrace,
      );

      return {
        'languageCode': 'en',
        'countryCode': null,
        'countryName': null,
        'locationAvailable': false,
      };
    }
  }
}
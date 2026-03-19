import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'language_service.dart';

/// Service to get user location and detect appropriate language
class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    await LanguageService.setLocationPermissionRequested();
    return await Geolocator.requestPermission();
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get country code from position
  static Future<String?> getCountryCodeFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
      return null;
    } catch (e) {
      print('Error getting country from position: $e');
      return null;
    }
  }

  /// Detect language based on user's location
  static Future<String> detectLanguageFromLocation() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) {
        return 'en'; // Default to English if location not available
      }

      final countryCode = await getCountryCodeFromPosition(position);
      if (countryCode == null) {
        return 'en';
      }

      return LanguageService.getLanguageFromCountryCode(countryCode);
    } catch (e) {
      print('Error detecting language: $e');
      return 'en';
    }
  }

  /// Get suggested language with location info
  static Future<Map<String, dynamic>> getSuggestedLanguage() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) {
        return {
          'languageCode': 'en',
          'countryCode': null,
          'countryName': null,
          'locationAvailable': false,
        };
      }

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final countryCode = placemark.isoCountryCode ?? 'US';
        final languageCode = LanguageService.getLanguageFromCountryCode(countryCode);

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
    } catch (e) {
      print('Error getting suggested language: $e');
      return {
        'languageCode': 'en',
        'countryCode': null,
        'countryName': null,
        'locationAvailable': false,
      };
    }
  }
}

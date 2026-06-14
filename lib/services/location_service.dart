import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import "app_logger.dart";
import 'language_service.dart';

class LocationService {
  static Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }

  static Future<LocationPermission> requestPermission() async {
    await LanguageService.setLocationPermissionRequested();
    return Geolocator.requestPermission();
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final bool serviceEnabled = await isLocationServiceEnabled();

      if (!serviceEnabled) {
        Applogger.w('Location services are disabled');
        return null;
      }

      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();

        if (permission == LocationPermission.denied) {
          Applogger.w('Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Applogger.w('Location permission permanently denied');

        return null;
      }

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (e, stackTrace) {
      Applogger.e('Error getting location', e, stackTrace);

      return null;
    }
  }

  static Future<String?> getCountryCodeFromPosition(Position position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }

      return null;
    } catch (e, stackTrace) {
      Applogger.e('Error getting country from position', e, stackTrace);

      return null;
    }
  }

  static Future<String> detectLanguageFromLocation() async {
    try {
      final Position? position = await getCurrentPosition();

      if (position == null) {
        return 'en';
      }

      final String? countryCode = await getCountryCodeFromPosition(position);

      if (countryCode == null) {
        return 'en';
      }

      return LanguageService.getLanguageFromCountryCode(countryCode);
    } catch (e, stackTrace) {
      Applogger.e('Error detecting language', e, stackTrace);

      return 'en';
    }
  }

  static Future<Map<String, dynamic>> getSuggestedLanguage() async {
    try {
      final Position? position = await getCurrentPosition();

      if (position == null) {
        return {
          'languageCode': 'en',
          'countryCode': null,
          'countryName': null,
          'locationAvailable': false,
        };
      }

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;

        final String countryCode = placemark.isoCountryCode ?? 'US';

        final String languageCode = LanguageService.getLanguageFromCountryCode(
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
      Applogger.e('Error getting suggested language', e, stackTrace);

      return {
        'languageCode': 'en',
        'countryCode': null,
        'countryName': null,
        'locationAvailable': false,
      };
    }
  }
}

import 'package:geolocator/geolocator.dart';
import '../constants/app_strings.dart';

class UserLocationResult {
  final double latitude;
  final double longitude;
  final bool isDemo;

  const UserLocationResult({
    required this.latitude,
    required this.longitude,
    required this.isDemo,
  });
}

class LocationService {
  LocationService._();

  /// Requests location permissions and fetches current GPS coordinates.
  /// Falls back to Islamabad demo coordinates if denied or on simulator/error.
  static Future<UserLocationResult> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const UserLocationResult(
          latitude: AppStrings.demoLatitude,
          longitude: AppStrings.demoLongitude,
          isDemo: true,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const UserLocationResult(
            latitude: AppStrings.demoLatitude,
            longitude: AppStrings.demoLongitude,
            isDemo: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const UserLocationResult(
          latitude: AppStrings.demoLatitude,
          longitude: AppStrings.demoLongitude,
          isDemo: true,
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return UserLocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        isDemo: false,
      );
    } catch (_) {
      // Safe fallback to demo coordinates on error
      return const UserLocationResult(
        latitude: AppStrings.demoLatitude,
        longitude: AppStrings.demoLongitude,
        isDemo: true,
      );
    }
  }

  /// Calculates geodesic distance between two points in meters using Haversine formula
  static double calculateDistanceInMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Converts meters to miles rounded to 1 decimal place matching React Native geolib logic
  static String convertMetersToMiles(double meters) {
    final miles = meters * 0.000621371;
    return miles.toStringAsFixed(1);
  }
}

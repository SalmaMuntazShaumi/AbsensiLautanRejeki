import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Office coordinates (replace with your actual office location)
  static const double OFFICE_LATITUDE = -6.197728;
  static const double OFFICE_LONGITUDE = 106.758653;

  // Radius in meters (100 meters)
  static const double RADIUS_METERS = 100.0;

  /// Check if location service is enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  static Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status;
  }

  /// Get current position
  static Future<Position> getCurrentPosition() async {
    try {
      final status = await Permission.location.request();

      if (status.isDenied) {
        throw Exception('Location permission denied');
      } else if (status.isPermanentlyDenied) {
        throw Exception('Location permission permanently denied. Please enable it in settings.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return position;
    } catch (e) {
      print(e);
      throw Exception('Failed to get location: $e');
    }
  }

  /// Check if user is within office radius
  static Future<bool> isWithinOfficeRadius() async {
    try {
      final position = await getCurrentPosition();

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        OFFICE_LATITUDE,
        OFFICE_LONGITUDE,
      );

      print('Distance from office: ${distance.toStringAsFixed(2)} meters');

      return distance <= RADIUS_METERS;
    } catch (e) {
      throw Exception('Failed to verify location: $e');
    }
  }

  /// Get distance from office in meters
  static Future<double> getDistanceFromOffice() async {
    try {
      final position = await getCurrentPosition();

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        OFFICE_LATITUDE,
        OFFICE_LONGITUDE,
      );

      return distance;
    } catch (e) {
      throw Exception('Failed to calculate distance: $e');
    }
  }
}


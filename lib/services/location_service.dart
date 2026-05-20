import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';

class LocationService {

  /// Check if location service is enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permission
  static Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  /// Get current position
  static Future<Position> getCurrentPosition() async {
    try {
      final status = await Permission.location.request();

      if (status.isDenied) {
        throw Exception('Izin lokasi ditolak.');
      } else if (status.isPermanentlyDenied) {
        throw Exception(
          'Izin lokasi ditolak permanen. Aktifkan di Pengaturan aplikasi.',
        );
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan lokasi: $e');
    }
  }

  /// Check if user is within office radius.
  /// Koordinat & radius diambil dari AppConfig (SharedPreferences / dart-define).
  static Future<bool> isWithinOfficeRadius() async {
    try {
      final position = await getCurrentPosition();

      final lat    = await AppConfig.getOfficeLat();
      final lng    = await AppConfig.getOfficeLng();
      final radius = await AppConfig.getOfficeRadius();

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      print('[LocationService] Jarak dari kantor: ${distance.toStringAsFixed(1)} m '
          '(radius: $radius m)');

      return distance <= radius;
    } catch (e) {
      throw Exception('Gagal verifikasi lokasi: $e');
    }
  }

  /// Get distance from office in meters
  static Future<double> getDistanceFromOffice() async {
    try {
      final position = await getCurrentPosition();

      final lat = await AppConfig.getOfficeLat();
      final lng = await AppConfig.getOfficeLng();

      return Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );
    } catch (e) {
      throw Exception('Gagal menghitung jarak: $e');
    }
  }
}
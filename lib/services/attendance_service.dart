import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'location_service.dart';

class AttendanceService {

  // =========================
  // GET CURRENT TIME
  // =========================
  static String getCurrentTime() {

    return DateFormat(
      'HH:mm',
    ).format(
      DateTime.now(),
    );
  }

  // =========================
  // ATTENDANCE STATUS
  // =========================
  static String getAttendanceStatus() {

    final now = DateTime.now();

    final limit = DateTime(
      now.year,
      now.month,
      now.day,
      8,
      30,
    );

    return now.isAfter(limit)
        ? 'Telat'
        : 'Tepat Waktu';
  }

  // =========================
  // EARLY OUT CHECK
  // =========================
  static bool isEarlyOut() {

    final now = DateTime.now();

    final limit = DateTime(
      now.year,
      now.month,
      now.day,
      16,
      50,
    );

    print('NOW: $now');
    print('LIMIT: $limit');
    print('IS EARLY: ${now.isBefore(limit)}');

    return now.isBefore(limit);
  }

  // =========================
  // VERIFY OFFICE RADIUS
  // =========================
  static Future<bool>
  verifyOfficeRadius() async {

    return await LocationService
        .isWithinOfficeRadius();
  }

  // =========================
  // GET OFFICE DISTANCE
  // =========================
  static Future<double>
  getOfficeDistance() async {

    return await LocationService
        .getDistanceFromOffice();
  }
}
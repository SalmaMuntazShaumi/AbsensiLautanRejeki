import 'package:dio/dio.dart';

import '../models/attendance_model.dart';

class AttendanceRepository {

  final Dio dio = Dio(

    BaseOptions(
      baseUrl: 'http://192.168.0.31:8000/',
    ),
  );

  // =========================
  // GET TODAY ATTENDANCE
  // =========================
  Future<AttendanceModel> getTodayAttendance({
    required String token,
  }) async {

    try {

      final response = await dio.get(

        'api/attendance/today',

        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data['data'];

      if (data == null) {

        return AttendanceModel();
      }

      return AttendanceModel.fromJson(data);

    } catch (e) {

      throw Exception(
        'Failed to get attendance: $e',
      );
    }
  }

  // =========================
  // CHECK IN
  // =========================
  Future<AttendanceModel> checkIn({

    required String token,
    required String photo,

  }) async {

    try {

      final response = await dio.post(

        '/api/check-in',

        data: {
          'photo': photo,
        },

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return AttendanceModel.fromJson(
        response.data['data'],
      );

    } catch (e) {

      throw Exception(
        'Check in failed: $e',
      );
    }
  }

  // =========================
  // CHECK OUT
  // =========================
  Future<AttendanceModel> checkOut({

    required String token,
    required String photo,
    String? reason,

  }) async {

    try {

      final response = await dio.post(

        '/api/check-out',

        data: {
          'photo': photo,
          'early_out_reason': reason,
        },

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return AttendanceModel.fromJson(
        response.data['data'],
      );

    } catch (e) {

      throw Exception(
        'Check out failed: $e',
      );
    }
  }
}
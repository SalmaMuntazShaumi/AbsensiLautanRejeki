import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lautanrejeki/models/attendance_history_model.dart';

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
  // CLOCK IN
  // =========================
  Future<AttendanceModel> clockIn({

    required String token,
    required File photo,

  }) async {

    try {

      final formData = FormData.fromMap({

        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'clockin.jpg',
        ),

      });

      final response = await dio.post(

        'api/clock-in',

        data: formData,

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
        'Clock in failed: $e',
      );
    }
  }

  // =========================
  // CLOCK OUT
  // =========================
  Future<AttendanceModel> clockOut({

    required String token,
    String? reason,

  }) async {

    try {

      final response = await dio.post(

        'api/clock-out',

        data: {
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
        'Clock out failed: $e',
      );
    }
  }

  Future<List<AttendanceHistoryModel>>
  fetchAttendanceHistory(
      String token,
      ) async {

    try {

      final response = await dio.get(

        'api/history',

        options: Options(
          headers: {

            'Accept': 'application/json',

            'Authorization': 'Bearer $token',
          },
        ),
      );

      final List data =
      response.data['data'];

      print(response.data);

      return data.map((item) {

        return AttendanceHistoryModel
            .fromJson(item);

      }).toList();

    } catch (e) {

      throw Exception(
        'Failed to fetch history: $e',
      );
    }
  }
}
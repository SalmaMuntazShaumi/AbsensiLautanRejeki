
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lautanrejeki/config/app_config.dart';
import 'package:lautanrejeki/models/attendance_history_model.dart';
import 'package:http/http.dart' as http;
import 'package:lautanrejeki/services/notification_service.dart';

import '../models/attendance_model.dart';

class AttendanceRepository {

  /// Buat Dio instance dengan baseUrl dari AppConfig.
  /// Dipanggil setiap kali method dieksekusi agar selalu pakai URL terkini.
  Future<Dio> _getDio() async {
    final baseUrl = await AppConfig.getBaseUrl();
    final companyId = await AppConfig.getCompanyId();
    final headers = <String, dynamic>{
      'Accept': 'application/json',
    };
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;

    return Dio(BaseOptions(
      baseUrl: '$baseUrl/',
      responseType: ResponseType.json, // ← tambahkan ini
      contentType: 'application/json',
      headers: headers,
    ));
  }

  // =========================
  // GET TODAY ATTENDANCE
  // =========================
  Future<AttendanceModel> getTodayAttendance({
    required String token,
  }) async {
    try {
      final dio = await _getDio();
      final companyId = await AppConfig.getCompanyId();
      final reqHeaders = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      if (companyId != null && companyId.isNotEmpty) reqHeaders['X-Company-Id'] = companyId;

      final response = await dio.get(
        'api/attendance/today',
        options: Options(
          headers: reqHeaders,
        ),
      );

      print('TODAY RESPONSE: ${response.data}'); // ← tambah ini
      final responseData = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final data = responseData['data'];
      if (data == null) return AttendanceModel();

      print('DATA: $data'); // ← tambah ini

      return AttendanceModel.fromJson(data);
    } catch (e, stackTrace) {
      print('ERROR: $e'); // ← tambah ini
      print('STACK: $stackTrace'); // ← tambah ini
      throw Exception('Failed to get attendance: $e');
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
      final dio = await _getDio();
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'clockin.jpg',
        ),
      });

      final companyId = await AppConfig.getCompanyId();
      final reqHeaders = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      if (companyId != null && companyId.isNotEmpty) reqHeaders['X-Company-Id'] = companyId;

      final response = await dio.post(
        'api/clock-in',
        data: formData,
        options: Options(
          headers: reqHeaders,
        ),
      );

      await NotificationService.instance.cancelClockInIfAlreadyClockedIn(token);

      return AttendanceModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Clock in failed: $e');
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
      final dio = await _getDio();
      final companyId = await AppConfig.getCompanyId();
      final reqHeaders = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      if (companyId != null && companyId.isNotEmpty) reqHeaders['X-Company-Id'] = companyId;

      final response = await dio.post(
        'api/clock-out',
        data: {'early_out_reason': reason},
        options: Options(
          headers: reqHeaders,
        ),
      );

      return AttendanceModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Clock out failed: $e');
    }
  }

  // repositories/attendance_repository.dart
  Future<List<AttendanceHistoryModel>> fetchAttendanceHistory(String token) async {
    final apiUrl = await AppConfig.getBaseUrl();

    final companyId = await AppConfig.getCompanyId();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;

    final response = await http.get(
      Uri.parse('$apiUrl/api/attendance/history'), // ← endpoint baru
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List list = data['data'];
      return list.map((e) => AttendanceHistoryModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Gagal mengambil riwayat');
  }

  /// Get attendance hari ini dengan token (untuk notification service)
  Future<Map<String, dynamic>?> getAttendanceTodayByToken(String token) async {
    try {
      final dio = await _getDio();

      final companyId = await AppConfig.getCompanyId();
      final reqHeaders = <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      if (companyId != null && companyId.isNotEmpty) reqHeaders['X-Company-Id'] = companyId;

      final response = await dio.get(
        'api/attendance/today',
        options: Options(
          headers: reqHeaders,
        ),
      );

      print('Attendance today response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            // Return data atau null jika belum ada attendance
            return data['data'] ?? data;
          }
        } catch (e) {
          print('Error parsing attendance: $e');
          return null;
        }
      }

      return null;
    } catch (e) {
      print('Error fetching attendance today: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllAttendanceHistory(
      String token, {
        String? date,
        String? week,
        String? month,
        String? year,
        String? startDate,
        String? endDate,
      }) async {
    final apiUrl = await AppConfig.getBaseUrl();

    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date;
    if (week != null) queryParams['week'] = week;
    if (month != null) queryParams['month'] = month;
    if (year != null) queryParams['year'] = year;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final uri = Uri.parse('$apiUrl/api/history').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    throw Exception(data['message'] ?? 'Gagal mengambil data');
  }

}
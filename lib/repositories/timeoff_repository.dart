import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TimeOffRepository {
  final String apiUrl = 'http://192.168.0.31:8000/';

  Future<void> createTimeOff({
    required String token,
    required String type,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}api/time-off'),

        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },

        body: {
          'type': type,
          'start_date': startDate,
          'end_date': endDate,
          'reason': reason,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(
          data['message'] ??
              'Failed to submit time off',
        );
      }
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception(
        'Submit time off error: $e',
      );
    }
  }

  Future<List<dynamic>> getTimeOff({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${apiUrl}api/time-off'),

      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    return data;
  }
}
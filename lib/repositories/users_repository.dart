import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UsersRepository {
  final String apiUrl = 'http://192.168.0.31:8000/';

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String phone,
    required String birthdate,
    File? image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiUrl}api/profile/update'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['birthdate'] = birthdate;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            image.path,
          ),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
          data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${apiUrl}api/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception('Failed to fetch user data: ${data['message'] ?? 'Unknown error'}');
      }
    } on SocketException {
      print('Fetch user data network error');
      throw Exception('Network error: Unable to connect to server');
    } on FormatException {
      print('Fetch user data format error');
      throw Exception('Invalid response format from server');
    } catch (e) {
      print('Fetch user data error: $e');
      throw Exception('Failed to fetch user data: $e');
    }
  }
}


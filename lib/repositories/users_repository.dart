import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lautanrejeki/config/app_config.dart';
import 'package:lautanrejeki/models/user_model.dart';

class UsersRepository {

  Future<String> _baseUrl() => AppConfig.getBaseUrl();

  Future<UserModel> updateProfile({
    required String token,
    required String name,
    required String phone,
    required String email,
    required String birthdate,
    File? image,
  }) async {
    final apiUrl = await _baseUrl();
    final companyId = await AppConfig.getCompanyId();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/api/profile/update'),
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;
    request.headers.addAll(headers);

    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['email'] = email;
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
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    }

    throw Exception(
      data['message'] ?? 'Failed to update profile',
    );
  }

  // users_repository.dart — update fetchUserData agar support keduanya
  Future<UserModel> fetchUserData(String token) async {
    try {
      final apiUrl = await _baseUrl();
      final companyId = await AppConfig.getCompanyId();
      final headers = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;

      final response = await http.get(
        Uri.parse('$apiUrl/api/user'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch user data');
      }
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
}
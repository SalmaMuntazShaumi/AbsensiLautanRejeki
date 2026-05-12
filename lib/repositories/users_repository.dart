import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UsersRepository {
  final String apiUrl = 'http://192.168.0.31:8000/';

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


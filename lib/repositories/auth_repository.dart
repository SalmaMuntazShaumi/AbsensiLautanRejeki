import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String apiUrl = 'http://192.168.0.31:8000/';

  /// Login user with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final JsonEncoder encoder = const JsonEncoder();
      final body = encoder.convert({
        'email': email,
        'password': password,
      });

      print('Sending login request to ${apiUrl}api/login with body: $body');

      final response = await http.post(
        Uri.parse('${apiUrl}api/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Login request timeout');
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully logged in
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            return data;
          } else {
            throw Exception('Invalid response format');
          }
        } catch (e) {
          throw Exception('Error parsing login response: $e');
        }
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        try {
          final data = jsonDecode(response.body);
          
          String message = 'Invalid email or password';
          
          if (data is Map<String, dynamic>) {
            if (data['message'] != null && data['message'] is String) {
              message = data['message'] as String;
            } else if (data['errors'] != null && data['errors'] is Map) {
              final errors = data['errors'] as Map;
              if (errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  message = firstError.first?.toString() ?? 'Authentication error';
                } else if (firstError != null) {
                  message = firstError.toString();
                }
              }
            } else if (data['error'] != null && data['error'] is String) {
              message = data['error'] as String;
            }
          }
          
          throw Exception(message);
        } catch (parseError) {
          print('Error parsing login response: $parseError');
          throw Exception('Login failed: Invalid server response');
        }
      } else {
        throw Exception('Login failed with status code: ${response.statusCode}');
      }
    } on SocketException {
      print('Login network error');
      throw Exception('Network error: Unable to connect to server');
    } on FormatException {
      print('Login format error');
      throw Exception('Invalid response format from server');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  /// Register user with email, password, and role
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
    required String birthDate,
  }) async {
    try {
      final JsonEncoder encoder = const JsonEncoder();
      final body = encoder.convert({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
        'birthdate': birthDate,
      });

      print('Sending register request to ${apiUrl}api/register with body: $body');

      final response = await http.post(
        Uri.parse('${apiUrl}api/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Register request timeout');
        },
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully registered
        return true;
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        try {
          final data = jsonDecode(response.body);

          String message = 'Registration failed';

          if (data is Map<String, dynamic>) {
            if (data['message'] != null && data['message'] is String) {
              message = data['message'] as String;
            } else if (data['errors'] != null && data['errors'] is Map) {
              final errors = data['errors'] as Map;
              if (errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  message = firstError.first?.toString() ?? 'Validation error';
                } else if (firstError != null) {
                  message = firstError.toString();
                }
              }
            } else if (data['error'] != null && data['error'] is String) {
              message = data['error'] as String;
            }
          }

          throw Exception(message);
        } catch (parseError) {
          print('Error parsing response: $parseError');
          throw Exception('Registration failed: Invalid server response');
        }
      } else if (response.statusCode == 409) {
        // Conflict - user already exists
        throw Exception('User with this email already exists');
      } else {
        throw Exception('Registration failed with status code: ${response.statusCode}');
      }
    } on SocketException {
      print('Register network error');
      throw Exception('Network error: Unable to connect to server');
    } on FormatException {
      print('Register format error');
      throw Exception('Invalid response format from server');
    } catch (e) {
      print('Register error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      print('User logged out');
      // Clear user session or token here
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout failed: $e');
    }
  }
}

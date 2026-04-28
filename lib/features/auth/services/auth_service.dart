import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'] ?? data['access_token'] ?? '';

        if (token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return true;
        }
      }
      return false;
    } catch (e) {
      print("CONNECTION ERROR: $e");
      return false;
    }
  }

  // UPDATE: Fungsi Register sekarang mengembalikan Map agar bisa membawa pesan error
  Future<Map<String, dynamic>> register(String name, String email, String password, String nim) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'nim': nim,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> logout() async {
    final token = await get_token();
    final response = await http.post(
      Uri.parse('$base_url/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return true;
    }
    return false;
  }

  static Future<String?> get_token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
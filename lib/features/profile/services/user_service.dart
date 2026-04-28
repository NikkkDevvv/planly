import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/user_model.dart';

class UserService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, String>> _get_headers() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('auth_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch current user profile data
  Future<UserModel> get_current_user() async {
    final headers = await _get_headers();
    final response = await http.get(
      Uri.parse('$base_url/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  /// Update user profile data
  Future<UserModel> update_profile({
    required String name,
    String? email,
    String? nim,
    String? major,
    int? semester,
  }) async {
    final headers = await _get_headers();

    final Map<String, dynamic> updateData = {'name': name};

    if (email != null) updateData['email'] = email;
    if (nim != null) updateData['nim'] = nim;
    if (major != null) updateData['major'] = major;
    if (semester != null) updateData['semester'] = semester;

    final response = await http.put(
      Uri.parse('$base_url/profile'),
      headers: headers,
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  /// Logout user
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove('auth_token');
  }
}

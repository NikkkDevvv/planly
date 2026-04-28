import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/models/course_model.dart';

class CourseService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  // Header wajib sesuai standar Laravel API
  Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Tambahkan jika sudah ada sistem login
  };

  // 1. Menampilkan semua daftar mata kuliah (GET /api/courses)
  Future<List<CourseModel>> get_courses() async {
    final response = await http.get(
      Uri.parse('$base_url/courses'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => CourseModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load courses: ${response.statusCode}');
    }
  }

  // 2. Menambah mata kuliah baru (POST /api/courses)
  Future<CourseModel> create_course(Map<String, dynamic> course_data) async {
    print("DEBUG SEND DATA: ${jsonEncode(course_data)}");

    final response = await http.post(
      Uri.parse('$base_url/courses'),
      headers: _getHeaders(),
      body: jsonEncode(course_data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      print("ERROR RESPONSE: ${response.body}");
      throw Exception('Failed to create course: ${response.body}');
    }
  }

  // 3. Melihat detail satu mata kuliah (GET /api/courses/{id})
  Future<CourseModel> get_course_detail(int id) async {
    final response = await http.get(
      Uri.parse('$base_url/courses/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get course detail');
    }
  }

  // 4. Mengubah data mata kuliah (PUT /api/courses/{id})
  Future<CourseModel> update_course(int course_id, Map<String, dynamic> course_data) async {
    final response = await http.put(
      Uri.parse('$base_url/courses/$course_id'),
      headers: _getHeaders(),
      body: jsonEncode(course_data),
    );

    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update course: ${response.body}');
    }
  }

  // 5. Menghapus mata kuliah (DELETE /api/courses/{id})
  Future<void> delete_course(int course_id) async {
    final response = await http.delete(
      Uri.parse('$base_url/courses/$course_id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete course');
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/models/course_model.dart';

class CourseService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<CourseModel>> get_courses(int user_id) async {
    try {
      final response = await http.get(
        Uri.parse('$base_url/courses?user_id=$user_id'),
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => CourseModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      return [
        CourseModel(
          id: 1,
          user_id: user_id,
          course_code: 'JMK45',
          name: 'Data Dummy',
          credits: 3,
          lecturer: 'Pak Dummy',
          room: 'Ruang Dummy Guys',
          day_of_week: 'Monday',
          start_time: '08:00',
          end_time: '10:00',
          color_hex: '#3498db',
        ),
      ];
    }
  }

  Future<CourseModel> create_course(Map<String, dynamic> course_data) async {
    try {
      final response = await http.post(
        Uri.parse('$base_url/courses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(course_data),
      );

      if (response.statusCode == 201) {
        return CourseModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create course');
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));

      return CourseModel(
        id: DateTime.now().millisecondsSinceEpoch,
        user_id: course_data['user_id'],
        course_code: course_data['course_code'],
        name: course_data['name'],
        credits: course_data['credits'],
        lecturer: course_data['lecturer'],
        room: course_data['room'],
        day_of_week: course_data['day_of_week'],
        start_time: course_data['start_time'],
        end_time: course_data['end_time'],
        color_hex: course_data['color_hex'] ?? '#3498db',
      );
    }
  }

  Future<CourseModel> update_course(
    int course_id,
    Map<String, dynamic> course_data,
  ) async {
    final response = await http.put(
      Uri.parse('$base_url/courses/$course_id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course_data),
    );

    if (response.statusCode == 200) {
      return CourseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update course');
    }
  }

  Future<void> delete_course(int course_id) async {
    final response = await http.delete(
      Uri.parse('$base_url/courses/$course_id'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete course');
    }
  }
}

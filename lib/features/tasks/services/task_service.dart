import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/task_model.dart';

class TaskService {
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

  Future<List<TaskModel>> get_all_tasks() async {
    final headers = await _get_headers();
    final response = await http.get(
      Uri.parse('$base_url/tasks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => TaskModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }
  }

  Future<List<TaskModel>> get_tasks_by_course(int course_id) async {
    final headers = await _get_headers();
    final response = await http.get(
      Uri.parse('$base_url/tasks?course_id=$course_id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => TaskModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load course tasks');
    }
  }

  Future<TaskModel> create_task(Map<String, dynamic> task_data) async {
    final headers = await _get_headers();
    final response = await http.post(
      Uri.parse('$base_url/tasks'),
      headers: headers,
      body: jsonEncode(task_data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  Future<TaskModel> update_task(int task_id, Map<String, dynamic> task_data) async {
    final headers = await _get_headers();
    final response = await http.put(
      Uri.parse('$base_url/tasks/$task_id'),
      headers: headers,
      body: jsonEncode(task_data),
    );

    if (response.statusCode == 200) {
      return TaskModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<bool> finish_task(int task_id) async {
    final headers = await _get_headers();
    final response = await http.patch(
      Uri.parse('$base_url/tasks/$task_id/finish'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  Future<bool> delete_task(int task_id) async {
    final headers = await _get_headers();
    final response = await http.delete(
      Uri.parse('$base_url/tasks/$task_id'),
      headers: headers,
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
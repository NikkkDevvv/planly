import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../auth/models/task_model.dart';

class TaskService {
  final String base_url = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<TaskModel>> get_tasks_by_course(int courseId) async {
    try {
      final response = await http.get(Uri.parse('$base_url/tasks?course_id=$courseId'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => TaskModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        TaskModel(
          id: 101,
          userId: 1,
          courseId: courseId,
          title: 'Assignment 1: lorem ipsum dolor sit amet.',
          description: 'lorem ipsum dolor sit amet .',
          deadlineDate: '2026-10-25',
          deadlineTime: '23:59',
          status: 'pending',
          isPriority: true,
        ),
        TaskModel(
          id: 102,
          userId: 1,
          courseId: courseId,
          title: 'lorem ipsum dolor sit amet.',
          description: 'lorem ipsum dolor sit amet.',
          deadlineDate: '2026-11-01',
          deadlineTime: '10:00',
          status: 'pending',
          isPriority: false,
        )
      ];
    }
  }
}